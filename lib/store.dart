
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Store {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Map<String, dynamic> getProfile() {
    final data = _prefs.getString('profile');
    if (data != null) return jsonDecode(data);
    return _defaultProfile;
  }

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _prefs.setString('profile', jsonEncode(profile));
  }

  static List<Map<String, dynamic>> getOrders() {
    final data = _prefs.getString('orders');
    if (data == null) return List.from(_defaultOrders);
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> saveOrders(List<Map<String, dynamic>> orders) async {
    await _prefs.setString('orders', jsonEncode(orders));
  }

  static Map<String, dynamic> get _defaultProfile => {
    'name': 'Шаурмичка',
    'manager': 'Менеджер',
    'city': 'Москва',
    'opened': '20.02.2222',
    'registered': '2012',
    'served': '0',
    'rating': '-',
    'positions': '0',
  };

  static List<Map<String, dynamic>> get _defaultOrders => [
    
  ];
}