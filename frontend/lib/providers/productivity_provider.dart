import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

class ProductivityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalDbService _localDbService = LocalDbService();

  List<Task> _tasks = [];
  List<TimeSlot> _slots = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  List<TimeSlot> get slots => _slots;
  bool get isLoading => _isLoading;

  Future<void> loadDailyData(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      // First load from local DB for fast response
      _tasks = await _localDbService.getPendingLocalTasks();
      _slots = await _localDbService.getLocalTimeSlots();

      // Then attempt real API fetch
      final apiTasks = await _apiService.getTasks(date);
      final apiSlots = await _apiService.getTimeSlots(date);
      
      _tasks = apiTasks;
      _slots = apiSlots;

    } catch (e) {
      print('Network fail, relying on local DB: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String name, DateTime date) async {
    // Note: No edit or delete method in provider to enforce Immutability
    final newTask = Task(taskName: name, date: date.toIso8601String());
    
    // Optimistic UI & Local DB
    await _localDbService.saveTask(newTask);
    _tasks.add(newTask);
    notifyListeners();

    try {
      await _apiService.createTask(newTask);
    } catch (e) {
      print('Failed to sync to server');
    }
  }

  Future<void> completeTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = Task(
        id: task.id, 
        taskName: task.taskName, 
        date: task.date, 
        isCompleted: true
      );
      notifyListeners();
      await _apiService.completeTask(task.id!);
      await _localDbService.saveTask(_tasks[index]);
    }
  }

  Future<void> addTimeSlot(TimeSlot slot) async {
    _slots.add(slot);
    notifyListeners();
    
    await _localDbService.saveTimeSlot(slot);
    try {
      await _apiService.syncSlots([slot]);
    } catch (e) {
      print('Failed to sync slots');
    }
  }
}
