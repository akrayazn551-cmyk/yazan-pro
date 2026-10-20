import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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

class LockAndSubscriptionGate extends StatefulWidget {
  const LockAndSubscriptionGate({Key? key}) : super(key: key);

  @override
  _LockAndSubscriptionGateState createState() => _LockAndSubscriptionGateState();
}

class _LockAndSubscriptionGateState extends State<LockAndSubscriptionGate> {
  bool _isUnlocked = false;
  final String _savedPin = "1234";
  final TextEditingController _pinController = TextEditingController();

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

  void _updatePin(String newPin) {
    setState(() {
      _savedPin = newPin;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث رمز PIN بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: !_isUnlocked
          ? Scaffold(
              appBar: AppBar(title: const Text('قفل الأمان المحاسبي - Yazan Pro')),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 80, color: Colors.indigo),
                    const SizedBox(height: 20),
                    const Text('أدخل رمز PIN للدخول للدفاتر والمالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'رمز PIN (الافتراضي: 1234)',
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
                        child: const Text('فتح النظام المحاسبي', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ProfessionalMainScreen(
              currentPin: _savedPin,
              onPinChanged: _updatePin,
            ),
    );
  }
}

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

  final List<Map<String, dynamic>> _ledgerTransactions = [];
  final List<Map<String, dynamic>> _customers = [];

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
          exp += (item['amount'] as num).toDouble();
        }
      }
    }
    totalIncomes = inc;
    totalExpenses = exp;
  }

  void _addCustomer(String name, String phone, double debt, double creditLimit, String dueDate) {
    setState(() {
      _customers.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'phone': phone,
        'debt': debt,
        'creditLimit': creditLimit,
        'dueDate': dueDate,
      });
    });
  }

  void _showChangePinDialog() {
    final newPinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير رمز PIN الأمان'),
        content: TextField(
          controller: newPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'أدخل رمز PIN الجديد'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (newPinController.text.trim().isNotEmpty) {
                widget.onPinChanged(newPinController.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('حفظ الرمز'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardTab(
        totalIncomes: totalIncomes,
        totalExpenses: totalExpenses,
        currency: selectedCurrency,
        transactions: _ledgerTransactions,
      ),
      LedgerTab(
        onAddTransaction: _addTransaction,
        onReverseTransaction: _reverseTransaction,
        transactions: _ledgerTransactions,
        currency: selectedCurrency,
      ),
      CustomersTab(
        onAddCustomer: _addCustomer,
        customers: _customers,
        transactions: _ledgerTransactions,
        onAddTransaction: _addTransaction,
        currency: selectedCurrency,
      ),
      ReportsTab(
        totalIncomes: totalIncomes,
        totalExpenses: totalExpenses,
        customerCount: _customers.length,
        currency: selectedCurrency,
        onChangePin: _showChangePinDialog,
        ledgerTransactions: _ledgerTransactions,
        customers: _customers,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yazan Pro - المحاسب الاحترافي'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            DropdownButton<String>(
              value: selectedCurrency,
              dropdownColor: Colors.indigo,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              underline: Container(),
              onChanged: (String? newCurr) {
                if (newCurr != null) {
                  setState(() {
                    selectedCurrency = newCurr;
                  });
                }
              },
              items: <String>['\$', 'ل.س', 'ر.س', 'د.إ', '€']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'دفتر الأستاذ'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء والديون'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير والإعدادات'),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final double totalIncomes;
  final double totalExpenses;
  final String currency;
  final List<Map<String, dynamic>> transactions;

  const DashboardTab({
    Key? key,
    required this.totalIncomes,
    required this.totalExpenses,
    required this.currency,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double netProfit = totalIncomes - totalExpenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildCard('إجمالي الوارد', '$totalIncomes $currency', Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildCard('إجمالي الصادر', '$totalExpenses $currency', Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          _buildCard('صافي الموقف المالي (الأرباح)', '$netProfit $currency', Colors.indigo, isFullWidth: true),
          const SizedBox(height: 20),
          const Text('سجل الحركة المالية الحديثة:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          transactions.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('لا توجد قيد محاسبية مسجلة')))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[transactions.length - 1 - index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          item['isIncome'] ? Icons.add_circle : Icons.remove_circle,
                          color: item['isReversed'] ? Colors.grey : (item['isIncome'] ? Colors.green : Colors.red),
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(decoration: item['isReversed'] ? TextDecoration.lineThrough : null),
                        ),
                        subtitle: Text('${item['date']} | حساب: ${item['accountType']}'),
                        trailing: Text(
                          '${item['amount']} $currency',
                          style: TextStyle(fontWeight: FontWeight.bold, color: item['isReversed'] ? Colors.grey : (item['isIncome'] ? Colors.green : Colors.red)),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color, {bool isFullWidth = false}) {
    return Card(
      elevation: 3,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class LedgerTab extends StatefulWidget {
  final Function(String, double, bool, String, {String? customerId}) onAddTransaction;
  final Function(int, String) onReverseTransaction;
  final List<Map<String, dynamic>> transactions;
  final String currency;

  const LedgerTab({
    Key? key,
    required this.onAddTransaction,
    required this.onReverseTransaction,
    required this.transactions,
    required this.currency,
  }) : super(key: key);

  @override
  _LedgerTabState createState() => _LedgerTabState();
}

class _LedgerTabState extends State<LedgerTab> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _accountType = 'صندوق رئيسي';
  bool _isIncome = true;

  void _submitEntry() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) return;

    widget.onAddTransaction(title, amount, _isIncome, _accountType);
    _titleController.clear();
    _amountController.clear();
    Navigator.of(context).pop();
  }

  void _showReverseDialog(int index) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسوية قيد عكسي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('المحاسبة لا تسمح بالحذف المباشر. يرجى كتابة سبب الإلغاء/التسوية:'),
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'السبب')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                widget.onReverseTransaction(index, reasonController.text);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('إجراء قيد عكسي'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تسجيل قيد محاسبي جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'بيان القيد المحاسبي')),
              TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ')),
              DropdownButtonFormField<String>(
                value: _accountType,
                items: ['صندوق رئيسي', 'حساب بنكي', 'مصروف تشغيلي', 'مشتريات/مبيعات']
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) => setState(() => _accountType = val!),
                decoration: const InputDecoration(labelText: 'نوع الحساب المقابل'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(label: const Text('قيد مدين (وارد)'), selected: _isIncome, onSelected: (_) => setState(() => _isIncome = true)),
                  const SizedBox(width: 10),
                  ChoiceChip(label: const Text('قيد دائن (صادر)'), selected: !_isIncome, onSelected: (_) => setState(() => _isIncome = false)),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submitEntry,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: const Text('حفظ القيد المحاسبي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.transactions.isEmpty
          ? const Center(child: Text('دفتر الأستاذ فارغ حالياً'))
          : ListView.builder(
              itemCount: widget.transactions.length,
              itemBuilder: (ctx, index) {
                final item = widget.transactions[index];
                return Card(
                  color: item['isReversed'] ? Colors.grey.shade200 : Colors.white,
                  child: ListTile(
                    title: Text(item['title'], style: TextStyle(decoration: item['isReversed'] ? TextDecoration.lineThrough : null)),
                    subtitle: Text('${item['date']} | ${item['accountType']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item['amount']} ${widget.currency}', style: TextStyle(color: item['isReversed'] ? Colors.grey : (item['isIncome'] ? Colors.green : Colors.red), fontWeight: FontWeight.bold)),
                        if (!item['isReversed'])
                          IconButton(icon: const Icon(Icons.undo, color: Colors.orange), onPressed: () => _showReverseDialog(index)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.post_add, color: Colors.white),
      ),
    );
  }
}

class CustomersTab extends StatefulWidget {
  final Function(String, String, double, double, String) onAddCustomer;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> transactions;
  final Function(String, double, bool, String, {String? customerId}) onAddTransaction;
  final String currency;

  const CustomersTab({
    Key? key,
    required this.onAddCustomer,
    required this.customers,
    required this.transactions,
    required this.onAddTransaction,
    required this.currency,
  }) : super(key: key);

  @override
  _CustomersTabState createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _debtController = TextEditingController();
  final _limitController = TextEditingController();
  final _dueDateController = TextEditingController();

  void _submitCustomer() {
    fin
