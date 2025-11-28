import 'package:flutter/material.dart';
import '../models/uml_class.dart';

class TextEditorDialog extends StatefulWidget {
  final UmlClass umlClass;

  const TextEditorDialog({super.key, required this.umlClass});

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  late TextEditingController _classNameController;
  late TextEditingController _attributesController;
  late TextEditingController _methodsController;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.umlClass.className);
    _attributesController = TextEditingController(
      text: widget.umlClass.attributes.join('\n'),
    );
    _methodsController = TextEditingController(
      text: widget.umlClass.methods.join('\n'),
    );
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _attributesController.dispose();
    _methodsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Class',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Class Name:'),
            const SizedBox(height: 8),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter class name',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Attributes (one per line):'),
            const SizedBox(height: 8),
            TextField(
              controller: _attributesController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter attributes, one per line',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Methods (one per line):'),
            const SizedBox(height: 8),
            TextField(
              controller: _methodsController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter methods, one per line',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final updatedClass = widget.umlClass.copyWith(
                      className: _classNameController.text.isNotEmpty
                          ? _classNameController.text
                          : 'ClassName',
                      attributes: _attributesController.text
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList(),
                      methods: _methodsController.text
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .toList(),
                    );
                    Navigator.of(context).pop(updatedClass);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





