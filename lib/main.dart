import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YazanProApp());
}

class YazanProApp extends StatelessWidget {
  const YazanProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yazan Pro Accounting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const LockAndSubscriptionGate(),
    );
  }
}

// --- 1. بوابات الحماية والتفعيل مع الحفظ التلقائي ---
class LockAndSubscriptionGate extends StatefulWidget {
  const LockAndSubscriptionGate({Key? key}) : super(key: key);

  @override
  _LockAndSubscriptionGateState createState() => _LockAndSubscriptionGateState();
}

class _LockAndSubscriptionGateState extends State<LockAndSubscriptionGate> {
  bool _isActivated = false;
  bool _isUnlocked = false;
  bool _isLoading = true;
  String _savedPin = "1234";

  final TextEditingController _activationCodeController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isActivated = prefs.getBool('isActivated') ?? false;
      _savedPin = prefs.getString('savedPin') ?? "1234";
      _isLoading = false;
    });
  }

  Future<void> _activateApp() async {
    int currentMonth = DateTime.now().month;
    String validCode = "YZNPRO-$currentMonth-2026";

    if (_activationCodeController.text.trim().toUpperCase() == validCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isActivated', true);
      setState(() {
        _isActivated = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تفعيل اشتراك النظام بنجاح وحفظه دائمياً!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز التفعيل الشهري غير صحيح!')),
        );
      }
    }
  }

  void _unlockApp() {
    if (_pinController.text == _savedPin) {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز PIN الحماية غير صحيح!')),
      );
    }
  }

  Future<void> _updatePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedPin', newPin);
    setState(() {
      _savedPin = newPin;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ رمز PIN الجديد دائمياً!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: !_isActivated
          ? Scaffold(
              appBar: AppBar(title: const Text('تفعيل Yazan Pro المحاسبي')),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, size: 80, color: Colors.indigo),
                    const SizedBox(height: 20),
                    const Text(
                      'نظام يزن برو للمحاسبة والإدارة\nأدخل رمز الاشتراك الشهري',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _activationCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'رمز التفعيل (مثال: YZNPRO-10-2026)',
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _activateApp,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                        child: const Text('تفعيل النظام', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : !_isUnlocked
              ? Scaffold(
                  appBar: AppBar(title: const Text('قفل الأمان المحاسبي')),
                  body: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 80, color: Colors.indigo),
                        const SizedBox(height: 20),
                        const Text('أدخل رمز PIN للدخول للدفاتر والمالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'رمز PIN الخاص بك',
                            prefixIcon: Icon(Icons.security),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _unlockApp,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                            child: const Text('فتح النظام', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ProfessionalMainScreen(
                  currentPin: _savedPin,
                  onPinChanged: _updatePin,
                );
  }
}

// --- 2. الشاشة المحاسبية الرئيسية وحفظ البيانات التلقائي ---
class ProfessionalMainScreen extends StatefulWidget {
  final String currentPin;
  final Function(String) onPinChanged;

  const ProfessionalMainScreen({
    Key? key,
    required this.currentPin,
    required this.onPinChanged,
  }) : super(key: key);

  @override
  _ProfessionalMainScreenState createState() => _ProfessionalMainScreenState();
}

class _ProfessionalMainScreenState extends State<ProfessionalMainScreen> {
  int _currentIndex = 0;
  String selectedCurrency = "\$";

  double totalIncomes = 0.0;
  double totalExpenses = 0.0;

  List<Map<String, dynamic>> _ledgerTransactions = [];
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final ledgerString = prefs.getString('ledgerData');
    final customersString = prefs.getString('customersData');

    setState(() {
      if (ledgerString != null) {
        _ledgerTransactions = List<Map<String, dynamic>>.from(jsonDecode(ledgerString));
      }
      if (customersString != null) {
        _customers = List<Map<String, dynamic>>.from(jsonDecode(customersString));
      }
      _recalculateTotals();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ledgerData', jsonEncode(_ledgerTransactions));
    await prefs.setString('customersData', jsonEncode(_customers));
  }

  void _addTransaction(String title, double amount, bool isIncome, String accountType, {String? customerId}) {
    setState(() {
      _ledgerTransactions.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'customerId': customerId ?? '',
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'accountType': accountType,
        'isReversed': false,
        'date': DateTime.now().toString().substring(0, 16),
      });
      _recalculateTotals();
      _saveData();
    });
  }

  void _reverseTransaction(int index, String reason) {
    setState(() {
      final original = _ledgerTransactions[index];
      original['isReversed'] = true;

      _ledgerTransactions.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'customerId': original['customerId'] ?? '',
        'title': 'قيد تسوية عكسي: ${original['title']} ($reason)',
        'amount': original['amount'],
        'isIncome': !original['isIncome'],
        'accountType': 'تسوية إدارية',
        'isReversed': false,
        'date': DateTime.now().toString().substring(0, 16),
      });

      _recalculateTotals();
      _saveData();
    });
  }

  void _recalculateTotals() {
    double inc = 0.0;
    double exp = 0.0;
    for (var item in _ledgerTransactions) {
      if (item['isReversed'] == false) {
        if (item['isIncome'] == true) {
          inc += (item['amount'] as num).toDouble();
        } else {
          
