import 'package:flutter/material.dart';

/// Floating action button for adding a new todo item.
class AddTodoFab extends StatelessWidget {
  /// Creates an [AddTodoFab].
  const AddTodoFab({super.key, required this.onAdd});

  /// Callback to execute when a new todo is added.
  final Future<void> Function(String title) onAdd;

  Future<void> _showAddDialog(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _AddTodoDialog(),
    );

    if (title != null) {
      await onAdd(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    );
  }
}

class _AddTodoDialog extends StatefulWidget {
  const _AddTodoDialog();

  @override
  State<_AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<_AddTodoDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Task'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'E.g. Buy milk',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title cannot be empty';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
