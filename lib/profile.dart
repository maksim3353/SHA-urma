import 'package:flutter/material.dart';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _manager;
  late TextEditingController _city;
  late TextEditingController _address;
  late TextEditingController _opened;
  late TextEditingController _registered;
  late TextEditingController _positions;

  @override
  void initState() {
    super.initState();
    final p = Store.getProfile();
    _name = TextEditingController(text: p['name']);
    _manager = TextEditingController(text: p['manager']);
    _city = TextEditingController(text: p['city']);
    _address = TextEditingController(text: p['address']);
    _opened = TextEditingController(text: p['opened']);
    _registered = TextEditingController(text: p['registered']);
    _positions = TextEditingController(text: p['positions']);
  }

  void _save() async {
    final p = Store.getProfile();
    p['name'] = _name.text;
    p['manager'] = _manager.text;
    p['city'] = _city.text;
    p['address'] = _address.text;
    p['opened'] = _opened.text;
    p['registered'] = _registered.text;
    p['positions'] = _positions.text;

    await Store.saveProfile(p);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Сохранено'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFFE65100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _name.dispose();
    _manager.dispose();
    _city.dispose();
    _address.dispose();
    _opened.dispose();
    _registered.dispose();
    _positions.dispose();
    super.dispose();
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
              padding: EdgeInsets.fromLTRB(4, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Редактировать точку',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),

            // Контент
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Название точки'),
                    SizedBox(height: 8),
                    _Input(controller: _name, hint: 'SHA-урма'),

                    SizedBox(height: 20),

                    _Label('Заведующий'),
                    SizedBox(height: 8),
                    _Input(controller: _manager, hint: 'Иван Иванов'),

                    SizedBox(height: 20),

                    _Label('Город'),
                    SizedBox(height: 8),
                    _Input(controller: _city, hint: 'Москва'),

                    SizedBox(height: 20),

                    _Label('Адрес'),
                    SizedBox(height: 8),
                    _Input(controller: _address, hint: 'Тверская, 15'),

                    SizedBox(height: 20),

                    _Label('Дата основания'),
                    SizedBox(height: 8),
                    _Input(controller: _opened, hint: '12 марта 2024'),

                    SizedBox(height: 20),

                    _Label('Дата регистрации в SHA-урма'),
                    SizedBox(height: 8),
                    _Input(controller: _registered, hint: '5 марта 2024'),

                    SizedBox(height: 20),

                    _Label('Количество позиций'),
                    SizedBox(height: 8),
                    _Input(controller: _positions, hint: '24', suffix: 'шт'),

                    SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Сохранить',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6D4C41),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffix;

  _Input({required this.controller, required this.hint, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFF0EAE0)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3E2723)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontWeight: FontWeight.w400),
          suffixText: suffix,
          suffixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}