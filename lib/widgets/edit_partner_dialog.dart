import 'package:flutter/material.dart';
import '../models/partner.dart';

class EditPartnerDialog extends StatefulWidget {
  final Partner? partner;
  const EditPartnerDialog({super.key, this.partner});

  @override
  State<EditPartnerDialog> createState() => _EditPartnerDialogState();
}

class _EditPartnerDialogState extends State<EditPartnerDialog> {
  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController innController;
  late TextEditingController phoneController;
  String type = 'Поставщик';

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.partner?.code ?? '');
    nameController = TextEditingController(text: widget.partner?.name ?? '');
    innController = TextEditingController(text: widget.partner?.inn ?? '');
    phoneController = TextEditingController(text: widget.partner?.phone ?? '');
    type = widget.partner?.type ?? 'Поставщик';
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    innController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final code = codeController.text.trim();
    final name = nameController.text.trim();
    final inn = innController.text.trim();
    final phone = phoneController.text.trim();

    if (code.isEmpty || name.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все обязательные поля!')),
      );
      return;
    }

    final partner = Partner(
      id: widget.partner?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: code,
      name: name,
      type: type,
      inn: inn,
      phone: phone,
    );
    Navigator.of(context).pop(partner);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.partner == null ? 'Новый контрагент' : 'Редактировать контрагента'),
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
              onChanged: (val) => setState(() => type = val ?? 'Поставщик'),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }
}
