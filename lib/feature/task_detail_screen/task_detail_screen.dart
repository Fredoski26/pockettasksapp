import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../edit_screem/edit_task_screen.dart';
import '../model/task_model.dart';
import '../provider/task.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog(context);
                  break;
                case 'toggle':
                  context.read<TaskProvider>().toggleTaskCompletion(task.id);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(task.isCompleted ? Icons.undo : Icons.check),
                    const SizedBox(width: 8),
                    Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final currentTask = taskProvider.getTaskById(task.id) ?? task;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              currentTask.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: currentTask.isCompleted
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentTask.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  decoration: currentTask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (currentTask.note.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Note',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentTask.note,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          'Status',
                          currentTask.isCompleted ? 'Completed' : 'Active',
                          icon: currentTask.isCompleted
                              ? Icons.check_circle
                              : Icons.pending,
                          color: currentTask.isCompleted ? Colors.green : null,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Created',
                          DateFormat('MMM dd, yyyy at HH:mm').format(currentTask.createdAt),
                          icon: Icons.add,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Last Updated',
                          DateFormat('MMM dd, yyyy at HH:mm').format(currentTask.updatedAt),
                          icon: Icons.update,
                        ),
                        if (currentTask.dueDate != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            context,
                            'Due Date',
                            DateFormat('MMM dd, yyyy').format(currentTask.dueDate!),
                            icon: Icons.calendar_today,
                            color: currentTask.isOverdue ? Colors.red : null,
                          ),
                        ],
                        if (currentTask.isOverdue) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'This task is overdue',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      String label,
      String value, {
        IconData? icon,
        Color? color,
      }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to task list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}