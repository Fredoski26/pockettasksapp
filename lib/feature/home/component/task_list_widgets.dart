import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/task_model.dart';
import '../../provider/task.dart';


class TaskListWidgets {
  final BuildContext context;

  TaskListWidgets(this.context);

  Widget buildStatsCard(TaskProvider taskProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', taskProvider.totalTasks, Icons.list),
          _buildStatItem('Active', taskProvider.activeTasks, Icons.pending),
          _buildStatItem('Done', taskProvider.completedTasks, Icons.check_circle),
          if (taskProvider.overdueTasks > 0)
            _buildStatItem('Overdue', taskProvider.overdueTasks, Icons.warning,
                color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget buildFilterChips(TaskProvider taskProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', TaskFilter.all, taskProvider),
          const SizedBox(width: 8),
          _buildFilterChip('Active', TaskFilter.active, taskProvider),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', TaskFilter.completed, taskProvider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskFilter filter, TaskProvider taskProvider) {
    final isSelected = taskProvider.currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => taskProvider.setFilter(filter),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskList(
      TaskProvider taskProvider, {
        required Function(BuildContext, Task) onEditTask,
        required Function(BuildContext, Task, TaskProvider) onDeleteTask,
        required Function(BuildContext, Task) onTaskDetails,
      }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return _buildTaskItem(
          task,
          taskProvider,
          onEditTask: onEditTask,
          onDeleteTask: onDeleteTask,
          onTaskDetails: onTaskDetails,
        );
      },
    );
  }

  Widget _buildTaskItem(
      Task task,
      TaskProvider taskProvider, {
        required Function(BuildContext, Task) onEditTask,
        required Function(BuildContext, Task, TaskProvider) onDeleteTask,
        required Function(BuildContext, Task) onTaskDetails,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: task.isCompleted ? 1 : 2,
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => taskProvider.toggleTaskCompletion(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.note.isNotEmpty)
                Text(
                  task.note,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              if (task.dueDate != null)
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}',
                  style: TextStyle(
                    color: task.isOverdue ? Colors.red : Theme.of(context).colorScheme.outline,
                    fontWeight: task.isOverdue ? FontWeight.bold : null,
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEditTask(context, task);
                  break;
                case 'delete':
                  onDeleteTask(context, task, taskProvider);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
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
          onTap: () => onTaskDetails(context, task),
        ),
      ),
    );
  }
}