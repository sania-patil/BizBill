import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? _selectedMonth;
  String? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();

  List<Map<String, dynamic>> _expenses = [];
  Map<String, double> _totals = {
    "Food": 0.0,
    "Travelling": 0.0,
    "total": 0.0,
  };

  final List<Map<String, String>> _months = [
    {"value": "01", "label": "January"},
    {"value": "02", "label": "February"},
    {"value": "03", "label": "March"},
    {"value": "04", "label": "April"},
    {"value": "05", "label": "May"},
    {"value": "06", "label": "June"},
    {"value": "07", "label": "July"},
    {"value": "08", "label": "August"},
    {"value": "09", "label": "September"},
    {"value": "10", "label": "October"},
    {"value": "11", "label": "November"},
    {"value": "12", "label": "December"},
  ];

  final List<String> _categories = ["Food", "Travelling"];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final db = await DBHelper().db;

    String? whereClause;
    List<String>? whereArgs;

    if (_selectedMonth != null) {
      whereClause = "strftime('%m', date) = ?";
      whereArgs = [_selectedMonth!];
    }

    final expenses = await db.query(
      "expenses",
      where: whereClause,
      whereArgs: whereArgs,
    );

    Map<String, double> expenseMap = {};
    double total = 0.0;

    for (var e in expenses) {
      String category = e['category']?.toString() ?? "";
      double amount = (e['amount'] as num).toDouble();
      total += amount;
      expenseMap[category] = (expenseMap[category] ?? 0) + amount;
    }

    setState(() {
      _expenses = expenseMap.entries
          .map((e) => {"category": e.key, "amount": e.value})
          .toList();

      _totals = {
        "Food": expenseMap["Food"] ?? 0.0,
        "Travelling": expenseMap["Travelling"] ?? 0.0,
        "total": total,
      };
    });
  }

  Future<void> _addExpense() async {
    if (_selectedCategory == null || _amountController.text.isEmpty) return;

    final db = await DBHelper().db;
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    await db.insert("expenses", {
      "category": _selectedCategory,
      "amount": amount,
      "date": DateTime.now().toIso8601String(),
    });

    _amountController.clear();
    _selectedCategory = null;
    _fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Expenses"),
        backgroundColor: Colors.lightBlue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month dropdown
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              items: _months
                  .map((m) => DropdownMenuItem(
                        value: m["value"],
                        child: Text(m["label"]!),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMonth = val;
                });
                _fetchExpenses();
              },
              decoration: InputDecoration(
                labelText: "Select Month",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add new expense
            Card(
              color: Colors.lightBlue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Select Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addExpense,
                      child: const Text("Add Expense"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Totals
            Card(
              color: Colors.lightBlue[50],
              child: ListTile(
                title: const Text("Totals",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Food: ₹${_totals['Food']}"),
                    Text("Travelling: ₹${_totals['Travelling']}"),
                    Text("Total: ₹${_totals['total']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Expense Table
            Expanded(
              child: Card(
                color: Colors.lightBlue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Category-wise Expenses",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Expanded(
                      child: _expenses.isEmpty
                          ? const Center(child: Text("No expenses recorded"))
                          : SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text("Category")),
                                  DataColumn(label: Text("Amount")),
                                ],
                                rows: _expenses
                                    .map((e) => DataRow(cells: [
                                          DataCell(Text(e["category"])),
                                          DataCell(Text("₹${e["amount"]}")),
                                        ]))
                                    .toList(),
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
