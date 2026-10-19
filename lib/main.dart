import 'package:flutter/material.dart';

void main() {
  runApp(const YazanProApp());
}

class YazanProApp extends StatelessWidget {
  const YazanProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yazan Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SubscriptionCheckScreen(),
    );
  }
}

class SubscriptionCheckScreen extends StatefulWidget {
  const SubscriptionCheckScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionCheckScreenState createState() => _SubscriptionCheckScreenState();
}

class _SubscriptionCheckScreenState extends State<SubscriptionCheckScreen> {
  bool _isActive = false;
  final TextEditingController _codeController = TextEditingController();

  void _activate() {
    int currentMonth = DateTime.now().month;
    String validCode = "YZNPRO-$currentMonth-2026";

    if (_codeController.text.trim().toUpperCase() == validCode) {
      setState(() {
        _isActive = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تفعيل الاشتراك بنجاح!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كود التفعيل غير صحيح!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفعيل تطبيق يزن برو')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'الرجاء إدخال كود التفعيل الشهري لاستخدام التطبيق',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'كود التفعيل',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _activate,
                child: const Text('تفعيل'),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yazan Pro - لوحة التحكم'),
      ),
      body: const Center(
        child: Text(
          'أهلاً بك في تطبيق يزن برو، الاشتراك مفعل بنجاح!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
