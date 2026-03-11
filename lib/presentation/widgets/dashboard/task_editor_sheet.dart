import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  const TaskEditorSheet({
    super.key,
    this.initialTask,
  });

  final Task? initialTask;

  bool get isEditing => initialTask != null;

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _categoryController =
        TextEditingController(text: widget.initialTask?.category ?? 'work');
    _priority = widget.initialTask?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit task' : 'New task',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            items: TaskPriority.values
                .map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final category = _categoryController.text.trim();
                if (title.isEmpty || category.isEmpty) return;

                final navigator = Navigator.of(context);
                final notifier = ref.read(tasksControllerProvider.notifier);

                if (isEditing) {
                  await notifier.updateTask(
                    widget.initialTask!.copyWith(
                      title: title,
                      category: category,
                      priority: _priority,
                    ),
                  );
                } else {
                  await notifier.createTask(
                    title: title,
                    category: category,
                    priority: _priority,
                  );
                }

                if (mounted) navigator.pop();
              },
              child: Text(isEditing ? 'Save changes' : 'Create task'),
            ),
          ),
        ],
      ),
    );
  }
}
