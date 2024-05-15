import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MoneyManagerApp());
}

class MoneyManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MoneyManagerHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class MoneyManagerHomePage extends StatefulWidget {
  @override
  _MoneyManagerHomePageState createState() => _MoneyManagerHomePageState();
}

class _MoneyManagerHomePageState extends State<MoneyManagerHomePage> {
  final _incomeController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _expenses = [];
  double _income = 0.0;
  double _totalExpenses = 0.0;
  double _remainingAmount = 0.0;
  final _formKey = GlobalKey<FormState>();

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final amount = double.parse(_amountController.text);
        _expenses.add({
          'amount': amount,
          'description': _descriptionController.text,
        });
        _totalExpenses += amount;
        _remainingAmount = _income - _totalExpenses;
        _amountController.clear();
        _descriptionController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      _totalExpenses -= _expenses[index]['amount'];
      _remainingAmount = _income - _totalExpenses;
      _expenses.removeAt(index);
    });
  }

  void _setIncome() {
    setState(() {
      _income = double.parse(_incomeController.text);
      _remainingAmount = _income - _totalExpenses;
    });
    _incomeController.clear();
    Navigator.of(context).pop();
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSetIncomeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Income'),
          content: TextFormField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Income'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _setIncome,
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Manager'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: _showSetIncomeDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Total Income: \$$_income', style: TextStyle(fontSize: 20)),
            Text('Total Expenses: \$$_totalExpenses', style: TextStyle(fontSize: 20)),
            Text('Remaining Amount: \$$_remainingAmount', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Expanded(
              child: _expenses.isEmpty
                  ? Center(child: Text('No expenses added yet.'))
                  : ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return ListTile(
                          title: Text('${expense['description']}'),
                          subtitle: Text('\$${expense['amount']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteExpense(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _incomeController.dispose();
    super.dispose();
  }
}