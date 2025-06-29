import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../model/task_model.dart';
import '../service/data_base.dart';

enum TaskFilter { all, active, completed }
enum TaskSort { dueDate, createdDate }

class TaskProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.createdDate;
  bool _isLoading = false;

  List<Task> get tasks {
    List<Task> filteredTasks = _getFilteredTasks();
    return _getSortedTasks(filteredTasks);
  }

  TaskFilter get currentFilter => _currentFilter;
  TaskSort get currentSort => _currentSort;
  bool get isLoading => _isLoading;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get activeTasks => _tasks.where((task) => !task.isCompleted).length;
  int get overdueTasks => _tasks.where((task) => task.isOverdue).length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedTasks = await _databaseService.getAllTasks();
      _tasks.clear();
      _tasks.addAll(loadedTasks);
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String note = '',
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      note: note,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _databaseService.insertTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await _databaseService.updateTask(updatedTask);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _databaseService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    _currentSort = sort;
    notifyListeners();
  }

  List<Task> _getFilteredTasks() {
    switch (_currentFilter) {
      case TaskFilter.active:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return _tasks;
    }
  }

  List<Task> _getSortedTasks(List<Task> tasks) {
    switch (_currentSort) {
      case TaskSort.dueDate:
        tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.createdDate:
      default:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return tasks;
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
}