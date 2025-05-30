import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class KkmDevice {
  final String ip;
  final int port;
  bool isConnected;

  KkmDevice({
    required this.ip,
    required this.port,
    this.isConnected = false,
  });
}

class KKMManager extends ChangeNotifier {
  final List<KkmDevice> _devices = [];

  List<KkmDevice> get devices => List.unmodifiable(_devices);

  Future<void> addDevice(String ip, int port) async {
    try {
      log('[KKM] Попытка добавить кассу: $ip:$port');
      final isOnline = await checkDeviceOnline(ip, port);
      _devices.add(KkmDevice(ip: ip, port: port, isConnected: isOnline));
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }

  Future<void> updateDevice(int index, String newIp, int newPort) async {
    try {
      log('[KKM] Обновление кассы: ${_devices[index].ip} -> $newIp:$newPort');
      final isOnline = await checkDeviceOnline(newIp, newPort);
      _devices[index] = KkmDevice(ip: newIp, port: newPort, isConnected: isOnline);
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }

  void removeDevice(int index) {
    log('[KKM] Удаление кассы: ${_devices[index].ip}');
    _devices.removeAt(index);
    notifyListeners();
  }

  Future<bool> checkDeviceOnline(String ip, int port) async {
    try {
      log('[KKM] Проверка связи: $ip:$port');
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkAllStatuses() async {
    log('[KKM] Старт проверки статусов всех касс'); //на режим онлайн или офлайн
    for (int i = 0; i < _devices.length; i++) {
      final device = _devices[i];
      log('[KKM] Проверка кассы ${device.ip}:${device.port}');
      final isOnline = await checkDeviceOnline(device.ip, device.port);
      if (_devices[i].isConnected != isOnline) {
        _devices[i] = KkmDevice(
          ip: device.ip,
          port: device.port,
          isConnected: isOnline,
        );
      }
    }
    notifyListeners();
  }

  // Отправляет X-отчет на первую подключенную кассу
Future<String> sendXReport() async {
  final device = _devices.firstWhere((d) => d.isConnected);
  log('[KKM] Отправка X-отчета на ${device.ip}:${device.port}');

  Socket? socket;
  try {
    socket = await Socket.connect(device.ip, device.port, timeout: const Duration(seconds: 10));
    
    // Сначала ENQ (0x05), затем команда X-отчета для Retail 01 ФМ
    // 02 05 40 1E 00 00 00 5B 03 далее основной с расчетом CTR контрольного тега ебучего
    final packet = [0x05, 0x02, 0x05, 0x40, 0x1E, 0x00, 0x00, 0x00, 0x5B, 0x03];
    
    log('[KKM] Отправляемый пакет: ${packet.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    
    socket.add(packet);
    await socket.flush();

    // Ждем ответ от кассы
    final response = await socket.fold<List<int>>(
      <int>[], 
      (bytes, data) => bytes..addAll(data)
    ).timeout(const Duration(seconds: 10));

    await socket.close();
    log('[KKM] Ответ кассы: ${response.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    return 'X-отчет успешно снят! Ответ: ${String.fromCharCodes(response)}';

  } on TimeoutException {
    socket?.destroy();
    log('[KKM] Таймаут соединения');
    return 'Ошибка: касса не ответила за 10 секунд';
  } on SocketException catch (e) {
    socket?.destroy();
    log('[KKM] Ошибка сети: ${e.message}');
    return 'Сетевая ошибка: ${e.message}';
  } catch (e) {
    socket?.destroy();
    log('[KKM] Критическая ошибка: ${e.toString()}');
    return 'Ошибка: ${e.toString()}';
  } finally {
    await socket?.close();
  }
 }
}
