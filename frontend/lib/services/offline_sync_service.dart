import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class OfflineSyncService {
  static const String _queueKey = 'offline_mutation_queue';

  /// Save daily base data to device storage
  static Future<void> cacheDailyData(DateTime date, String dataKey, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = date.toIso8601String().split('T')[0];
      final key = 'daily_data_${dataKey}_$dateStr';
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to cache data: $e');
    }
  }

  /// Retrieve cached daily base data
  static Future<dynamic> getOfflineDailyData(DateTime date, String dataKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = date.toIso8601String().split('T')[0];
      final key = 'daily_data_${dataKey}_$dateStr';
      final cachedStr = prefs.getString(key);
      if (cachedStr != null) {
        return jsonDecode(cachedStr);
      }
    } catch (e) {
      debugPrint('Failed to retrieve offline data: $e');
    }
    return null;
  }

  /// Queue an action to be executed when network is available
  static Future<void> queueAction(String action, Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueStr = prefs.getString(_queueKey);
      List queue = queueStr != null ? jsonDecode(queueStr) : [];
      queue.add({'action': action, 'payload': payload});
      await prefs.setString(_queueKey, jsonEncode(queue));
      debugPrint('Action queued: $action');
    } catch (e) {
      debugPrint('Failed to queue action: $e');
    }
  }

  /// Process the queue. Uses the ApiService directly.
  static Future<bool> syncOfflineQueue(ApiService apiService) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueStr = prefs.getString(_queueKey);
      if (queueStr == null) return true;

      List queue = jsonDecode(queueStr);
      if (queue.isEmpty) return true;

      debugPrint('Starting offline sync. Queue size: ${queue.length}');
      
      bool allSuccessful = true;
      List failedQueue = [];

      for (var item in queue) {
        final action = item['action'];
        final payload = item['payload'];

        try {
          if (action == 'completeTask') {
            await apiService.completeTask(payload['taskId']);
          } else if (action == 'addTimeSlot') {
            // Using raw POST to avoid circular dependencies if needed, or apiService method
            // The payload must closely match the TimeSlot JSON
            await apiService.createSlotRaw(payload);
          } else if (action == 'deleteTimeSlot') {
            await apiService.deleteSlot(payload['id']);
          }
          debugPrint('Synced offline action: $action');
        } catch (e) {
          debugPrint('Failed executing offline action $action: $e');
          allSuccessful = false;
          failedQueue.add(item);
        }
      }

      await prefs.setString(_queueKey, jsonEncode(failedQueue));
      return allSuccessful;
    } catch (e) {
      debugPrint('Major failure during syncOfflineQueue: $e');
      return false;
    }
  }
}
