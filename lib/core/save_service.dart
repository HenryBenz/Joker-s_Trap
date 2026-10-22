import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/save_data.dart';

class SaveLoadResult {
  const SaveLoadResult(this.data, {required this.corrupt});

  final SaveData data;
  final bool corrupt;
}

class SaveService {
  static const key = 'jokers_trap_save_v1';

  Future<SaveLoadResult> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return SaveLoadResult(SaveData.initial(), corrupt: false);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('Save root is not an object');
      }
      final data = SaveData.fromJson(Map<String, dynamic>.from(decoded));
      return SaveLoadResult(data, corrupt: false);
    } catch (_) {
      final fresh = SaveData.initial();
      await save(fresh);
      return SaveLoadResult(fresh, corrupt: true);
    }
  }

  Future<void> save(SaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data.toJson()));
  }
}
