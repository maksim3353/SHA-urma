import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'create.dart';
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHA-урма',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFDF9F3),
        colorScheme: ColorScheme.light(primary: Color(0xFFE65100)),
      ),
      home: FeedScreen(),
    );
  }
}

// ============================================================
// ХРАНИЛИЩЕ (сохранение в SharedPreferences)
// ============================================================
class Store {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Map<String, String> getProfile() {
    final data = _prefs.getString('profile');
    if (data != null) {
      return Map<String, String>.from(jsonDecode(data));
    }
    return {
      'name': 'Шаурмичная',
      'manager': '',
      'city': '',
      'address': '',
      'opened': '',
      'registered': '',
      'served': '0',
      'rating': '0.0',
      'positions': '0',
    };
  }

  static Future<void> saveProfile(Map<String, String> profile) async {
    await _prefs.setString('profile', jsonEncode(profile));
  }

  // Активные заказы
  static List<Map<String, String>> getOrders() {
    final data = _prefs.getString('orders');
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
  }

  static Future<void> saveOrders(List<Map<String, String>> orders) async {
    await _prefs.setString('orders', jsonEncode(orders));
  }

  // История (завершённые)
  static List<Map<String, String>> getHistory() {
    final data = _prefs.getString('history');
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
  }

  static Future<void> saveHistory(List<Map<String, String>> history) async {
    await _prefs.setString('history', jsonEncode(history));
  }

  static String nextNumber() {
    final orders = getOrders();
    if (orders.isEmpty) return '1000';
    return (int.parse(orders.first['number']!) + 1).toString();
  }
}

// ============================================================
// ГЛАВНЫЙ ЭКРАН
// ============================================================
class FeedScreen extends StatefulWidget {
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Map<String, String> _profile;
  late List<Map<String, String>> _orders;
  late List<Map<String, String>> _history;

  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _profile = Store.getProfile();
      _orders = Store.getOrders();
      _history = Store.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF9F3),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Точка',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen()),
                      );
                      if (result == true) _load();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.edit_outlined,
                          color: Color(0xFFE65100), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
               
                  _buildStoreCard(),

                  SizedBox(height: 24),

               
                  _buildInfo(),

                  SizedBox(height: 24),

                  _buildToggle(),

                  SizedBox(height: 14),

            
                  if (!_showHistory) ..._buildActiveOrders(),
                  if (_showHistory) ..._buildHistory(),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateOrderScreen()),
          );
          if (result == true) _load();
        },
        backgroundColor: Color(0xFFE65100),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Новый заказ',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildStoreCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFDFB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ОТКРЫТО',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE65100),
                letterSpacing: 1.0,
              ),
            ),
          ),
          SizedBox(height: 14),
          Text(
            _profile['name'] ?? '',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3E2723),
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${_profile['city']}${_profile['city']!.isNotEmpty ? ' · ' : ''}${_profile['opened']}',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6D4C41),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                  child: _Stat(
                      value: _profile['served'] ?? '0', label: 'Обслужено')),
              Container(
                  width: 1,
                  height: 40,
                  color: Color(0xFF6D4C41).withOpacity(0.2)),
              Expanded(
                  child: _Stat(
                      value: _profile['rating'] ?? '0.0',
                      label: 'Оценка',
                      star: true)),
              Container(
                  width: 1,
                  height: 40,
                  color: Color(0xFF6D4C41).withOpacity(0.2)),
              Expanded(
                  child: _Stat(
                      value: _profile['positions'] ?? '0',
                      label: 'Позиции')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ИНФОРМАЦИЯ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF999999),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        _InfoRow(
            icon: Icons.person_outline,
            label: 'Заведующий',
            value: _profile['manager'] ?? '—'),
        _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Адрес',
            value: _profile['address'] ?? '—'),
        _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Открыта',
            value: _profile['opened'] ?? '—'),
        _InfoRow(
            icon: Icons.verified_outlined,
            label: 'В SHA-урма с',
            value: _profile['registered'] ?? '—'),
      ],
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFF0EAE0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _ToggleItem(
              label: 'Активные (${_orders.length})',
              active: !_showHistory,
              onTap: () => setState(() => _showHistory = false),
            ),
            _ToggleItem(
              label: 'История (${_history.length})',
              active: _showHistory,
              onTap: () => setState(() => _showHistory = true),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActiveOrders() {
    if (_orders.isEmpty) {
      return [
        _EmptyState(
          icon: Icons.receipt_long_outlined,
          text: 'Нет активных заказов',
        ),
      ];
    }

    return _orders.asMap().entries.map((e) {
      final i = e.key;
      final o = e.value;
      return _OrderCard(
        order: o,
        onComplete: () async {
          final orders = Store.getOrders();
          final history = Store.getHistory();
          final completed = orders.removeAt(i);
          history.insert(0, completed);
          await Store.saveOrders(orders);
          await Store.saveHistory(history);
          _load();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Заказ #${o['number']} завершён'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        onDelete: () async {
          final orders = Store.getOrders();
          orders.removeAt(i);
          await Store.saveOrders(orders);
          _load();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Заказ #${o['number']} удалён'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFC62828),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> _buildHistory() {
    if (_history.isEmpty) {
      return [
        _EmptyState(
          icon: Icons.history,
          text: 'История пуста',
        ),
      ];
    }

    return _history.map((o) {
      return _HistoryCard(order: o);
    }).toList();
  }
}


class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool star;

  _Stat({required this.value, required this.label, this.star = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (star) ...[
              Icon(Icons.star_rounded, size: 18, color: Color(0xFFE65100)),
              SizedBox(width: 2),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3E2723),
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6D4C41).withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xFFE65100), size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Color(0xFF999999), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, String> order;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  _OrderCard({
    required this.order,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6D4C41).withOpacity(0.05),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
  
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.restaurant_rounded,
                    color: Color(0xFFE65100), size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['name']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E2723),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('#${order['number']}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E8E82),
                                fontWeight: FontWeight.w500)),
                        _dot(),
                        Text(order['items']!,
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E8E82),
                                fontWeight: FontWeight.w500)),
                        _dot(),
                        Text(order['time']!,
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E8E82),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${order['price']} ₽',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE65100),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

      
          Row(
            children: [
             
              Expanded(
                child: GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 16, color: Color(0xFF2E7D32)),
                        SizedBox(width: 6),
                        Text(
                          'Завершить',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),

        
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFFC62828)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Color(0xFF9E8E82),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
class _ToggleItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  _ToggleItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Color(0xFF3E2723) : Color(0xFF9E8E82),
            ),
          ),
        ),
      ),
    );
  }
}

// Пустой экран
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Color(0xFFD9CFC2)),
          SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E8E82),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Карточка истории
class _HistoryCard extends StatelessWidget {
  final Map<String, String> order;

  _HistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFF0EAE0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.check_circle_outline,
                color: Color(0xFF2E7D32), size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['name']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('#${order['number']}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E8E82),
                            fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Color(0xFF9E8E82),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(order['items']!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E8E82),
                            fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Color(0xFF9E8E82),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(order['time']!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E8E82),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${order['price']} ₽',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}