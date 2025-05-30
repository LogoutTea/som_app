import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/kkm_manager.dart';

void showEditKkmDialog(BuildContext context, int index, KkmDevice device) {
  final ipController = TextEditingController(text: device.ip);
  final portController = TextEditingController(text: device.port.toString());
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Редактировать кассу'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'IP-адрес'),
                  validator: (value) => value == null || value.isEmpty 
                      ? 'Обязательное поле' 
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Порт'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Обязательное поле';
                    if (int.tryParse(value) == null) return 'Неверный формат';
                    return null;
                  },
                ),
                if (isLoading) const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  final isIpValid = ipController.text.isNotEmpty;
                  final port = int.tryParse(portController.text);
                  final isPortValid = port != null && port > 0;
                  
                  if (!isIpValid || !isPortValid) {
                    if (Navigator.canPop(ctx)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Проверьте правильность введенных данных'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  setState(() => isLoading = true);
                  
                  try {
                    final kkmManager = Provider.of<KKMManager>(ctx, listen: false);
                    await kkmManager.updateDevice(index, ipController.text, port);
                    await kkmManager.checkAllStatuses();
                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                  } catch (e) {
                    if (Navigator.canPop(ctx)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка обновления: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );
}
