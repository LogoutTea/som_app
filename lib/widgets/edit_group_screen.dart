import 'package:flutter/material.dart';
import '../models/product_group.dart';

class EditGroupScreen extends StatefulWidget {
  final ProductGroup group;
  final List<ProductGroup> allGroups;

  const EditGroupScreen({super.key, required this.group, required this.allGroups});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late TextEditingController nameController;
  String? parentGroupId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.group.name);
    parentGroupId = widget.group.parentId;
  }

  @override
  Widget build(BuildContext context) {
    final parentCandidates = widget.allGroups.where((g) => g.id != widget.group.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать группу')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Название группы'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: parentGroupId,
              decoration: const InputDecoration(labelText: 'Родительская группа'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Без родительской группы'),
                ),
                ...parentCandidates.map((g) => DropdownMenuItem<String?>(
                      value: g.id,
                      child: Text(g.name),
                    )),
              ],
              onChanged: (val) => setState(() => parentGroupId = val),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final updatedGroup = ProductGroup(
                    id: widget.group.id,
                    name: name,
                    parentId: parentGroupId,
                  );
                  Navigator.of(context).pop(updatedGroup);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
