import 'package:flutter/material.dart';
import '../models/activity_element.dart';
import '../models/sequence_element.dart';
import '../models/use_case_element.dart';
import '../models/state_machine_element.dart';

class ElementEditorDialog extends StatefulWidget {
  final dynamic element;

  const ElementEditorDialog({super.key, required this.element});

  @override
  State<ElementEditorDialog> createState() => _ElementEditorDialogState();
}

class _ElementEditorDialogState extends State<ElementEditorDialog> {
  late TextEditingController _labelController;
  late TextEditingController _descriptionController;
  late bool _isUseCase;

  @override
  void initState() {
    super.initState();
    String label = '';
    String description = '';
    _isUseCase = widget.element is UseCaseElement;
    
    if (widget.element is ActivityElement) {
      label = (widget.element as ActivityElement).label;
    } else if (widget.element is SequenceElement) {
      label = (widget.element as SequenceElement).label;
    } else if (widget.element is UseCaseElement) {
      final useCase = widget.element as UseCaseElement;
      label = useCase.label;
      description = useCase.description;
    } else if (widget.element is StateMachineElement) {
      label = (widget.element as StateMachineElement).label;
    }
    _labelController = TextEditingController(text: label);
    _descriptionController = TextEditingController(text: description);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Element',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Label:'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter label',
                      ),
                    ),
                    if (_isUseCase) ...[
                      const SizedBox(height: 16),
                      const Text('Functionalities/Description:'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 8,
                        minLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter functionalities or description (one per line)\nExample:\n- Login to system\n- View profile\n- Update settings',
                        ),
                      ),
                    ],
                  ],
                ),
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
                    dynamic updated;
                    if (widget.element is ActivityElement) {
                      updated = (widget.element as ActivityElement).copyWith(
                        label: _labelController.text,
                      );
                    } else if (widget.element is SequenceElement) {
                      updated = (widget.element as SequenceElement).copyWith(
                        label: _labelController.text,
                      );
                    } else if (widget.element is UseCaseElement) {
                      updated = (widget.element as UseCaseElement).copyWith(
                        label: _labelController.text,
                        description: _descriptionController.text,
                      );
                    } else if (widget.element is StateMachineElement) {
                      updated = (widget.element as StateMachineElement).copyWith(
                        label: _labelController.text,
                      );
                    }
                    Navigator.of(context).pop(updated);
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

