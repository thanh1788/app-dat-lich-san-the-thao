import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookingStorage {
  BookingStorage._();
  static final BookingStorage instance = BookingStorage._();

  static const _key = 'user_bookings_v2';

  Future<void> save(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      raw = prefs.getString('user_bookings_v1');
      if (raw == null || raw.isEmpty) return [];
    }
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (_) {
      return [];
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove('user_bookings_v1');
  }
}