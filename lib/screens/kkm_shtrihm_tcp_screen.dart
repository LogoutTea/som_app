import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/kkm_manager.dart';


class ShtrihMTcpConnectionScreen extends StatefulWidget {
  const ShtrihMTcpConnectionScreen({super.key});

  @override
  State<ShtrihMTcpConnectionScreen> createState() => _ShtrihMTcpConnectionScreenState();
}

class _ShtrihMTcpConnectionScreenState extends State<ShtrihMTcpConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingStatuses = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkStatuses();
    });
  }

  Future<void> _checkStatuses() async {
    if (!mounted) return;
    setState(() => _isCheckingStatuses = true);
    try {
      await Provider.of<KKMManager>(context, listen: false).checkAllStatuses();
    } finally {
      if (mounted) setState(() => _isCheckingStatuses = false);
    }
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить кассу?'),
        content: Text('Удалить кассу ${context.read<KKMManager>().devices[index].ip}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<KKMManager>().removeDevice(index);
              Navigator.pop(ctx);
              if (mounted) _checkStatuses(); // Обновляем статусы после удаления
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kkmManager = Provider.of<KKMManager>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Список касс',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                icon: _isCheckingStatuses
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Проверить статусы'),
                onPressed: _isCheckingStatuses
                    ? null
                    : () {
                        if (mounted) _checkStatuses();
                      },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: kkmManager.devices.isEmpty
                ? const Center(child: Text('Нет добавленных касс'))
                : ListView.separated(
                    itemCount: kkmManager.devices.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final device = kkmManager.devices[i];
                      return ListTile(
                        leading: Icon(
                          device.isConnected 
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: device.isConnected 
                              ? Colors.green 
                              : Colors.red,
                        ),
                        title: Text('${device.ip}:${device.port}'),
                        subtitle: Text(
                          device.isConnected 
                              ? 'Статус: Подключена' 
                              : 'Статус: Отключена',
                          style: TextStyle(
                            color: device.isConnected 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, i),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP-адрес',
                    hintText: 'Введите адрес WEB',
                  ),
                  validator: (value) => value == null || value.isEmpty 
                      ? 'Введите IP' 
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Порт',
                    hintText: 'Введите номер Порта WEB',
                  ),
                  validator: (value) => value == null || value.isEmpty 
                      ? 'Введите порт' 
                      : int.tryParse(value) == null 
                          ? 'Неверный формат порта' 
                          : null,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Добавить кассу'),
                    onPressed: _isLoading ? null : _addDevice,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDevice() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await Provider.of<KKMManager>(context, listen: false).addDevice(
        _ipController.text,
        int.parse(_portController.text),
      );
      _ipController.clear();
      _portController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Касса успешно добавлена'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
