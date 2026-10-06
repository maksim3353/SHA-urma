import 'package:flutter/material.dart';
import 'main.dart';

class CreateOrderScreen extends StatefulWidget {
  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _priceController = TextEditingController();
  final _itemsController = TextEditingController(text: '1');

  final _quickWords = [
    'Обычная', 'Большая', 'Острая', 'Сырная',
    'Двойной сыр', 'Без лука', 'С халапеньо', 'Вегетарианская',
  ];

  @override
  void initState() {
    super.initState();
    _numberController.text = Store.nextNumber();
  }

  void _addWord(String word) {
    final text = _nameController.text;
    if (text.isEmpty) {
      _nameController.text = word;
    } else {
      _nameController.text = '$text, $word';
    }
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _nameController.text.length),
    );
  }

  void _createOrder() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заполни название и цену'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFE65100),
        ),
      );
      return;
    }

    final orders = Store.getOrders();
    orders.insert(0, {
      'name': _nameController.text,
      'number': _numberController.text,
      'items': '${_itemsController.text} шт',
      'time': TimeOfDay.now().format(context),
      'price': _priceController.text,
    });
    Store.saveOrders(orders);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Заказ #${_numberController.text} создан'),
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
    _numberController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    _priceController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF9F3),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Зарегистрировать заказ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3E2723),
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              _Label('Номер заказа'),
              SizedBox(height: 8),
              _Input(controller: _numberController, hint: '1248'),

              SizedBox(height: 20),

              _Label('Название заказа'),
              SizedBox(height: 8),
              _Input(controller: _nameController, hint: 'Большая, Острая, Сырная'),

              SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickWords.map((w) {
                  return GestureDetector(
                    onTap: () => _addWord(w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFFFE0B2), width: 1.5),
                      ),
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              _Label('Количество'),
              SizedBox(height: 8),
              _Input(controller: _itemsController, hint: '1', suffix: 'шт'),

              SizedBox(height: 20),

              _Label('Примечания'),
              SizedBox(height: 8),
              _Input(controller: _noteController, hint: 'Без соуса, острый...', maxLines: 3),

              SizedBox(height: 20),

              _Label('Цена'),
              SizedBox(height: 8),
              _Input(controller: _priceController, hint: '320', suffix: '₽'),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Создать заказ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
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
  final int maxLines;
  final String? suffix;

  _Input({required this.controller, required this.hint, this.maxLines = 1, this.suffix});

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
        maxLines: maxLines,
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