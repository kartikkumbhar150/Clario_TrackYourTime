import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../services/offline_sync_service.dart';

class ProductivityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  List<TimeSlot> _slots = [];
  List<String> _categories = [
    'Study', 'DSA', 'Work', 'Gym', 'Sleep', 'Social Media', 'Gaming', 'Rest', 'Other'
  ];
  bool _isLoading = false;
  bool _isBackgroundRefreshing = false;
  String? _error;

  // Analytics
  Map<String, dynamic> _categoryBreakdown = {};
  Map<String, dynamic> _taskBreakdown = {};
  Map<String, dynamic> _productivityByCategory = {};
  String _aiInsights = '';
  double _productivityPercentage = 0;
  int _productivityIndex = 0;
  int _totalMinutes = 0;
  int _productiveMinutes = 0;
  int _wastedMinutes = 0;
  int _neutralMinutes = 0;
  int _totalTasks = 0;
  int _completedTasks = 0;

  // Weekly trend
  List<Map<String, dynamic>> _weeklyTrend = [];
  List<Map<String, dynamic>> _cumulativeFocus = [];
  bool _weeklyTrendLoaded = false;

  // AI Insights
  Map<String, dynamic> _aiInsightsData = {};
  bool _aiInsightsLoaded = false;

  // Heatmap
  Map<String, dynamic> _heatmapData = {};
  bool _heatmapLoaded = false;

  // Getters
  List<Task> get tasks => _tasks;
  List<TimeSlot> get slots => _slots;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isBackgroundRefreshing => _isBackgroundRefreshing;
  String? get error => _error;
  Map<String, dynamic> get categoryBreakdown => _categoryBreakdown;
  Map<String, dynamic> get taskBreakdown => _taskBreakdown;
  Map<String, dynamic> get productivityByCategory => _productivityByCategory;
  String get aiInsights => _aiInsights;
  double get productivityPercentage => _productivityPercentage;
  int get productivityIndex => _productivityIndex;
  int get totalMinutes => _totalMinutes;
  int get productiveMinutes => _productiveMinutes;
  int get wastedMinutes => _wastedMinutes;
  int get neutralMinutes => _neutralMinutes;
  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;
  List<Map<String, dynamic>> get weeklyTrend => _weeklyTrend;
  List<Map<String, dynamic>> get cumulativeFocus => _cumulativeFocus;
  bool get weeklyTrendLoaded => _weeklyTrendLoaded;
  Map<String, dynamic> get aiInsightsData => _aiInsightsData;
  bool get aiInsightsLoaded => _aiInsightsLoaded;
  Map<String, dynamic> get heatmapData => _heatmapData;
  bool get heatmapLoaded => _heatmapLoaded;

  Future<void> loadDailyData(DateTime date) async {
    // Attempt to load from offline cache first to unblock UI
    try {
      final cachedSlotsRaw = await OfflineSyncService.getOfflineDailyData(date, 'slots');
      if (cachedSlotsRaw != null) {
        _slots = (cachedSlotsRaw as List).map((e) => TimeSlot.fromJson(e)).toList();
      }
      final cachedTasksRaw = await OfflineSyncService.getOfflineDailyData(date, 'tasks');
      if (cachedTasksRaw != null) {
        _tasks = (cachedTasksRaw as List).map((e) => Task.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Cache read error: $e');
    }

    if (_slots.isEmpty && _tasks.isEmpty) {
      _isLoading = true;
    } else {
      _isBackgroundRefreshing = true;
    }
    _error = null;
    notifyListeners();

    try {
      // Background Sync any outstanding queue
      final hasConnection = !await _isOffline();
      if (hasConnection) {
        await OfflineSyncService.syncOfflineQueue(_apiService);
      }

      _tasks = await _apiService.getTasks(date);
      _slots = await _apiService.getTimeSlots(date);
      
      // Update Cache
      await OfflineSyncService.cacheDailyData(date, 'tasks', _tasks.map((t) => t.toJson()).toList());
      await OfflineSyncService.cacheDailyData(date, 'slots', _slots.map((s) => s.toJson()).toList());

      try {
        _categories = await _apiService.getCategories();
      } catch (e) {
        debugPrint('Using default categories: $e');
      }

      // Load analytics
      try {
        final analytics = await _apiService.getAnalytics('day', date: date);
        _totalMinutes = _parseIntSafe(analytics['totalMinutes']);
        _productiveMinutes = _parseIntSafe(analytics['productiveMinutes']);
        _wastedMinutes = _parseIntSafe(analytics['wastedMinutes']);
        _neutralMinutes = _parseIntSafe(analytics['neutralMinutes']);
        _productivityPercentage = double.tryParse(analytics['productivityPercentage']?.toString() ?? '0') ?? 0;
        _productivityIndex = _parseIntSafe(analytics['productivityIndex']);
        _totalTasks = _parseIntSafe(analytics['totalTasks']);
        _completedTasks = _parseIntSafe(analytics['completedTasks']);
        _categoryBreakdown = Map<String, dynamic>.from(analytics['categoryBreakdown'] ?? {});
        _taskBreakdown = Map<String, dynamic>.from(analytics['taskBreakdown'] ?? {});
        _productivityByCategory = Map<String, dynamic>.from(analytics['productivityByCategory'] ?? {});
        _aiInsights = analytics['insights']?.toString() ?? '';
      } catch (e) {
        debugPrint('Analytics fetch failed: $e');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load data: $e');
    }

    _isLoading = false;
    _isBackgroundRefreshing = false;
    notifyListeners();
  }

  Future<bool> _isOffline() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List) {
      return connectivityResult.contains(ConnectivityResult.none);
    }
    return connectivityResult == ConnectivityResult.none;
  }

  Future<void> loadWeeklyTrend({DateTime? date}) async {
    try {
      final data = await _apiService.getWeeklyTrend(date: date);
      _weeklyTrend = List<Map<String, dynamic>>.from(data['trend'] ?? []);
      _cumulativeFocus = List<Map<String, dynamic>>.from(data['cumulativeFocus'] ?? []);
      _weeklyTrendLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Weekly trend failed: $e');
    }
  }

  Future<void> loadAIInsights() async {
    try {
      _aiInsightsData = await _apiService.getAIInsights();
      _aiInsightsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AI insights failed: $e');
    }
  }

  Future<void> loadHeatmap({int? month, int? year}) async {
    try {
      _heatmapData = await _apiService.getHeatmapData(month: month, year: year);
      _heatmapLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Heatmap failed: $e');
    }
  }

  int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> addTask(String name, DateTime date) async {
    final now = DateTime.now();
    final cleanDate = DateTime(now.year, now.month, now.day, 12, 0, 0);
    final newTask = Task(taskName: name, date: cleanDate.toIso8601String());

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
        final isOfflineNow = await _isOffline();
        if (isOfflineNow) {
          await OfflineSyncService.queueAction('completeTask', {'taskId': task.id});
        } else {
          await _apiService.completeTask(task.id!);
        }
      } catch (e) {
        await OfflineSyncService.queueAction('completeTask', {'taskId': task.id});
        debugPrint('Queued complete task: $e');
      }
    }
  }

  Future<void> addTimeSlot(TimeSlot slot) async {
    // Optimistic Update
    _slots.removeWhere((s) => s.timeRange == slot.timeRange);
    _slots.add(slot);
    notifyListeners();

    try {
      final isOfflineNow = await _isOffline();
      if (isOfflineNow) {
        await OfflineSyncService.queueAction('addTimeSlot', slot.toJson());
      } else {
        final created = await _apiService.createSlot(slot);
        final idx = _slots.indexWhere((s) => s.timeRange == slot.timeRange);
        if (idx >= 0) _slots[idx] = created;
        notifyListeners();
      }
    } catch (e) {
      await OfflineSyncService.queueAction('addTimeSlot', slot.toJson());
      debugPrint('Queued addTimeSlot: $e');
    }
  }

  Future<void> updateTimeSlot(String id, {String? taskSelected, String? category, String? productivityType}) async {
    try {
      final updated = await _apiService.updateSlot(id,
          taskSelected: taskSelected,
          category: category,
          productivityType: productivityType);
      final index = _slots.indexWhere((s) => s.id == id);
      if (index >= 0) {
        _slots[index] = updated;
      }
      notifyListeners();
      loadDailyData(DateTime.now());
    } catch (e) {
      debugPrint('Failed to update time slot: $e');
    }
  }

  Future<void> deleteTimeSlot(String id) async {
    final oldSlots = List<TimeSlot>.from(_slots);
    _slots.removeWhere((s) => s.id == id);
    notifyListeners();

    try {
      final isOfflineNow = await _isOffline();
      if (isOfflineNow) {
        await OfflineSyncService.queueAction('deleteTimeSlot', {'id': id});
      } else {
        await _apiService.deleteSlot(id);
      }
    } catch (e) {
      await OfflineSyncService.queueAction('deleteTimeSlot', {'id': id});
      debugPrint('Queued delete time slot: $e');
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
    _taskBreakdown = {};
    _productivityByCategory = {};
    _aiInsights = '';
    _productivityPercentage = 0;
    _productivityIndex = 0;
    _totalMinutes = 0;
    _productiveMinutes = 0;
    _wastedMinutes = 0;
    _neutralMinutes = 0;
    _totalTasks = 0;
    _completedTasks = 0;
    _weeklyTrend = [];
    _cumulativeFocus = [];
    _weeklyTrendLoaded = false;
    _aiInsightsData = {};
    _aiInsightsLoaded = false;
    _heatmapData = {};
    _heatmapLoaded = false;
    _error = null;
    notifyListeners();
  }
}
