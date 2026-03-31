import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';

class ProductivityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  List<TimeSlot> _slots = [];
  List<String> _categories = [
    'Study', 'DSA', 'Work', 'Gym', 'Sleep', 'Social Media', 'Gaming', 'Rest', 'Other'
  ];
  bool _isLoading = false;
  String? _error;

  // Analytics
  Map<String, dynamic> _categoryBreakdown = {};
  String _aiInsights = '';
  double _productivityPercentage = 0;
  int _totalMinutes = 0;
  int _productiveMinutes = 0;
  int _wastedMinutes = 0;

  List<Task> get tasks => _tasks;
  List<TimeSlot> get slots => _slots;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get categoryBreakdown => _categoryBreakdown;
  String get aiInsights => _aiInsights;
  double get productivityPercentage => _productivityPercentage;
  int get totalMinutes => _totalMinutes;
  int get productiveMinutes => _productiveMinutes;
  int get wastedMinutes => _wastedMinutes;

  Future<void> loadDailyData(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _apiService.getTasks(date);
      _slots = await _apiService.getTimeSlots(date);

      try {
        _categories = await _apiService.getCategories();
      } catch (e) {
        debugPrint('Using default categories: $e');
      }

      // Load analytics
      try {
        final analytics = await _apiService.getAnalytics('day', date: date);
        _totalMinutes = (analytics['totalMinutes'] ?? 0) is int
            ? analytics['totalMinutes']
            : int.tryParse(analytics['totalMinutes'].toString()) ?? 0;
        _productiveMinutes = (analytics['productiveMinutes'] ?? 0) is int
            ? analytics['productiveMinutes']
            : int.tryParse(analytics['productiveMinutes'].toString()) ?? 0;
        _wastedMinutes = (analytics['wastedMinutes'] ?? 0) is int
            ? analytics['wastedMinutes']
            : int.tryParse(analytics['wastedMinutes'].toString()) ?? 0;
        _productivityPercentage = double.tryParse(
            analytics['productivityPercentage']?.toString() ?? '0') ?? 0;
        _categoryBreakdown = Map<String, dynamic>.from(
            analytics['categoryBreakdown'] ?? {});
        _aiInsights = analytics['insights']?.toString() ?? '';
      } catch (e) {
        debugPrint('Analytics fetch failed: $e');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String name, DateTime date) async {
    final newTask = Task(taskName: name, date: date.toIso8601String());

    try {
      final created = await _apiService.createTask(newTask);
      _tasks.add(created);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to create task: $e');
    }
  }

  Future<void> completeTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = Task(
        id: task.id,
        taskName: task.taskName,
        date: task.date,
        isCompleted: true,
      );
      notifyListeners();

      try {
        await _apiService.completeTask(task.id!);
      } catch (e) {
        _tasks[index] = task;
        notifyListeners();
        debugPrint('Failed to complete task: $e');
      }
    }
  }

  Future<void> addTimeSlot(TimeSlot slot) async {
    try {
      await _apiService.createSlot(slot);
      _slots.add(slot);
      notifyListeners();
      // Refresh analytics after adding a slot
      loadDailyData(DateTime.now());
    } catch (e) {
      debugPrint('Failed to create time slot: $e');
    }
  }

  Future<void> addCategory(String category) async {
    if (category.trim().isEmpty) return;
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
      try {
        await _apiService.updateCategories(_categories);
      } catch (e) {
        _categories.remove(category);
        notifyListeners();
      }
    }
  }

  Future<void> removeCategory(String category) async {
    if (_categories.contains(category)) {
      final oldCategories = List<String>.from(_categories);
      _categories.remove(category);
      notifyListeners();
      try {
        await _apiService.updateCategories(_categories);
      } catch (e) {
        _categories = oldCategories;
        notifyListeners();
      }
    }
  }

  void clearData() {
    _tasks = [];
    _slots = [];
    _categoryBreakdown = {};
    _aiInsights = '';
    _productivityPercentage = 0;
    _totalMinutes = 0;
    _productiveMinutes = 0;
    _wastedMinutes = 0;
    _error = null;
    notifyListeners();
  }
}
