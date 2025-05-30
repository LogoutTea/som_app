import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/partner.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  late Box<Partner> partnersBox;

  @override
  void initState() {
    super.initState();
    partnersBox = Hive.box<Partner>('partners');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Контрагенты')),
      body: ValueListenableBuilder(
        valueListenable: partnersBox.listenable(),
        builder: (context, Box<Partner> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Нет контрагентов'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final p = box.getAt(index)!;
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${p.type} | ИНН: ${p.inn} | Тел.: ${p.phone}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.code),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Удалить',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Удалить контрагента?'),
                            content: Text('Вы уверены, что хотите удалить "${p.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          box.deleteAt(index);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  final edited = await _showEditPartnerDialog(context, partner: p);
                  if (edited != null) {
                    box.putAt(index, edited);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final partner = await _showEditPartnerDialog(context);
          if (partner != null) {
            partnersBox.add(partner);
          }
        },
        tooltip: 'Добавить контрагента',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Partner?> _showEditPartnerDialog(BuildContext context, {Partner? partner}) async {
    final codeController = TextEditingController(text: partner?.code ?? '');
    final nameController = TextEditingController(text: partner?.name ?? '');
    final innController = TextEditingController(text: partner?.inn ?? '');
    final phoneController = TextEditingController(text: partner?.phone ?? '');
    String type = partner?.type ?? 'Поставщик';

    return await showDialog<Partner>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(partner == null ? 'Новый контрагент' : 'Редактировать контрагента'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Код'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Наименование'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Тип'),
                  items: const [
                    DropdownMenuItem(value: 'Поставщик', child: Text('Поставщик')),
                    DropdownMenuItem(value: 'Покупатель', child: Text('Покупатель')),
                    DropdownMenuItem(value: 'Поставщик/Покупатель', child: Text('Поставщик/Покупатель')),
                  ],
                  onChanged: (val) => type = val ?? 'Поставщик',
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: innController,
                  decoration: const InputDecoration(labelText: 'ИНН'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPartner = Partner(
                  id: partner?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  code: codeController.text.trim(),
                  name: nameController.text.trim(),
                  type: type,
                  inn: innController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                Navigator.pop(ctx, newPartner);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
