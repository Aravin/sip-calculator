import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculator_models.dart';

class PersistenceService {
  static const _key = 'saved_calculations';
  static const _maxItems = 50;

  static Future<List<SavedCalculation>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data == null) return [];
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.where((j) => j is Map<String, dynamic>).map((j) {
        try {
          return SavedCalculation.fromJson(j as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Skipping corrupt saved calculation: $e');
          return null;
        }
      }).whereType<SavedCalculation>().toList();
    } catch (e) {
      debugPrint('Error loading saved calculations: $e');
      return [];
    }
  }

  static Future<void> save(SavedCalculation calc) async {
    final list = await loadAll();
    list.add(calc);
    if (list.length > _maxItems) {
      list.removeRange(0, list.length - _maxItems);
    }
    await _persist(list);
  }

  static Future<void> delete(String id) async {
    final list = await loadAll();
    list.removeWhere((c) => c.id == id);
    await _persist(list);
  }

  static Future<void> _persist(List<SavedCalculation> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(list.map((c) => c.toJson()).toList());
    await prefs.setString(_key, data);
  }
}
