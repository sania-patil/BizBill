// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';

// class BillingScreen extends StatefulWidget {
//   const BillingScreen({super.key});

//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }

// class _BillingScreenState extends State<BillingScreen> {
//   List<Map<String, dynamic>> _bills = [];
//   double _pending = 0, _paid = 0, _total = 0;
//   String? _selectedMonth;



//   @override
//   void initState() {
//     super.initState();
//     _fetchBills();
//   }

//   Future<void> _fetchBills({String? month}) async {
//     final db = await DBHelper().db;
//     String where = "";
//     List<String> whereArgs = [];

//     if (month != null) {
//       where = "WHERE strftime('%m', date) = ?";
//       whereArgs = [month];
//     }

//     final bills = await db.rawQuery('''
//       SELECT b.id, p.name AS product_name, b.quantity, b.price, b.total_amount, b.status, b.date,
//              z.name AS bazar_name
//       FROM bills b
//       JOIN products p ON b.product_id = p.id
//       JOIN bazar z ON b.bazar_id = z.id
//       $where
//       ORDER BY b.date DESC
//     ''', whereArgs);

//     double pending = 0, paid = 0, total = 0;
//     for (var bill in bills) {
//       total += bill['total_amount'] as double;
//       if (bill['status'] == 'pending') {
//         pending += bill['total_amount'] as double;
//       } else {
//         paid += bill['total_amount'] as double;
//       }
//     }

//     setState(() {
//       _bills = bills;
//       _pending = pending;
//       _paid = paid;
//       _total = total;
//     });
//   }

//   Future<void> _markPaid(int id) async {
//     final db = await DBHelper().db;
//     await db.update('bills', {'status': 'paid'}, where: 'id = ?', whereArgs: [id]);
//     _fetchBills(month: _selectedMonth);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Billing")),
//       body: Column(
//         children: [
//           // Month filter
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DropdownButtonFormField<String>(
//               value: _selectedMonth,
//               hint: const Text("Filter by Month"),
//               items: _months.map((m) {
//                 return DropdownMenuItem(value: m, child: Text("Month $m"));
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => _selectedMonth = value);
//                 _fetchBills(month: value);
//               },
//             ),
//           ),

//           // Summary
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Text("Total: ₹$_total", style: const TextStyle(fontSize: 18)),
//                 Text("Paid: ₹$_paid", style: const TextStyle(color: Colors.green, fontSize: 16)),
//                 Text("Pending: ₹$_pending", style: const TextStyle(color: Colors.red, fontSize: 16)),
//               ],
//             ),
//           ),

//           const Divider(),

//           // Bills List
//           Expanded(
//             child: ListView.builder(
//               itemCount: _bills.length,
//               itemBuilder: (context, index) {
//                 final bill = _bills[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   child: ListTile(
//                     title: Text("${bill['product_name']} (${bill['bazar_name']})"),
//                     subtitle: Text(
//                       "Qty: ${bill['quantity']} x ₹${bill['price']} = ₹${bill['total_amount']}\nDate: ${bill['date']}"
//                     ),
//                     trailing: bill['status'] == 'pending'
//                         ? ElevatedButton(
//                             onPressed: () => _markPaid(bill['id'] as int),
//                             child: const Text("Mark Paid"),
//                           )
//                         : const Icon(Icons.check_circle, color: Colors.green),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class BillingScreen extends StatefulWidget {
//   final int bazarId;
//   const BillingScreen({super.key, required this.bazarId});

//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }

// class _BillingScreenState extends State<BillingScreen> {
//   final TextEditingController _productController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _discountController = TextEditingController();

//   List<Map<String, dynamic>> _bills = [];
//   double _total = 0;
//   double _paid = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBills();
//   }

//   Future<void> _fetchBills() async {
//     final db = await DBHelper().db;
//     final bills = await db.rawQuery('''
//       SELECT bills.*, products.name as product_name
//       FROM bills
//       LEFT JOIN products ON bills.product_id = products.id
//       WHERE bills.bazar_id = ?
//       ORDER BY bills.date DESC
//     ''', [widget.bazarId]);

//     double total = 0;
//     double paid = 0;

//     for (var bill in bills) {
//       final amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == 'paid') {
//         paid += amount;
//       }
//     }

//     setState(() {
//       _bills = bills;
//       _total = total;
//       _paid = paid;
//     });
//   }

//   Future<void> _addBill() async {
//     String product = _productController.text.trim();
//     int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
//     double price = double.tryParse(_priceController.text.trim()) ?? 0;
//     double discount = double.tryParse(_discountController.text.trim()) ?? 0;

//     if (product.isEmpty || price <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter product and valid price")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     // Insert product if not exists
//     final productId = await db.insert(
//       'products',
//       {'name': product},
//       conflictAlgorithm: ConflictAlgorithm.ignore,
//     );

//     final pid = productId > 0
//         ? productId
//         : (await db.query('products',
//                 where: 'name = ?', whereArgs: [product], limit: 1))
//             .first['id'] as int;

//     // Calculate total amount with discount
//     double totalAmount = qty * price;
//     totalAmount -= discount;

//     await db.insert('bills', {
//       'bazar_id': widget.bazarId,
//       'product_id': pid,
//       'quantity': qty,
//       'price': price,
//       'total_amount': totalAmount,
//       'status': 'pending',
//       'date': DateTime.now().toIso8601String().substring(0, 10),
//     });

//     _productController.clear();
//     _qtyController.clear();
//     _priceController.clear();
//     _discountController.clear();

//     _fetchBills();
//   }

//   Future<void> _markPaid(int billId) async {
//     final db = await DBHelper().db;
//     await db.update(
//       'bills',
//       {'status': 'paid'},
//       where: 'id = ?',
//       whereArgs: [billId],
//     );
//     _fetchBills();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double pending = _total - _paid;

//     // Group bills by date
//     Map<String, List<Map<String, dynamic>>> groupedBills = {};
//     for (var bill in _bills) {
//       String date = bill['date'];
//       if (!groupedBills.containsKey(date)) {
//         groupedBills[date] = [];
//       }
//       groupedBills[date]!.add(bill);
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Billing")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Display totals
//             Text("Total: ₹$_total", style: const TextStyle(fontSize: 18)),
//             Text("Paid: ₹$_paid",
//                 style: const TextStyle(fontSize: 18, color: Colors.green)),
//             Text("Pending: ₹$pending",
//                 style: const TextStyle(fontSize: 18, color: Colors.red)),
//             const Divider(),

//             // Bill entry form
//             TextField(
//               controller: _productController,
//               decoration: const InputDecoration(
//                   labelText: "Product Name", border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _qtyController,
//               decoration: const InputDecoration(
//                   labelText: "Quantity", border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(
//                   labelText: "Price per Quantity", border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _discountController,
//               decoration: const InputDecoration(
//                   labelText: "Discount (optional)",
//                   border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _addBill,
//               child: const Text("Add Bill"),
//             ),
//             const Divider(),

//             // List of bills grouped by date
//             Expanded(
//               child: _bills.isEmpty
//                   ? const Center(child: Text("No bills yet"))
//                   : ListView(
//                       children: groupedBills.entries.map((entry) {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(entry.key,
//                                 style: const TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                             ...entry.value.map((bill) {
//                               return Card(
//                                 child: ListTile(
//                                   title: Text("${bill['product_name']}"),
//                                   subtitle: Text(
//                                       "Qty: ${bill['quantity']} x ₹${bill['price']}\nTotal: ₹${bill['total_amount']}"),
//                                   trailing: bill['status'] == 'pending'
//                                       ? ElevatedButton(
//                                           onPressed: () => _markPaid(bill['id']),
//                                           child: const Text("Mark Paid"),
//                                         )
//                                       : const Icon(Icons.check_circle,
//                                           color: Colors.green),
//                                 ),
//                               );
//                             }),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class BillingScreen extends StatefulWidget {
//   final int bazarId;

//   const BillingScreen({super.key, required this.bazarId});

//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }


// class _BillingScreenState extends State<BillingScreen> {
//   final TextEditingController _productController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _discountController = TextEditingController();

//   List<Map<String, dynamic>> _bills = [];
//   List<Map<String, dynamic>> _bazars = [];

//   int? _selectedBazarId;
//   double _total = 0;
//   double _paid = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBazars();
//   }

//   Future<void> _fetchBazars() async {
//     final db = await DBHelper().db;
//     final bazars = await db.query("bazar");
//     setState(() {
//       _bazars = bazars;
//     });
//   }

//   Future<void> _fetchBills() async {
//     if (_selectedBazarId == null) return;

//     final db = await DBHelper().db;
//     final bills = await db.rawQuery('''
//       SELECT bills.*, products.name as product_name
//       FROM bills
//       LEFT JOIN products ON bills.product_id = products.id
//       WHERE bills.bazar_id = ?
//       ORDER BY bills.date DESC
//     ''', [_selectedBazarId]);

//     double total = 0;
//     double paid = 0;

//     for (var bill in bills) {
//       final amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == 'paid') {
//         paid += amount;
//       }
//     }

//     setState(() {
//       _bills = bills;
//       _total = total;
//       _paid = paid;
//     });
//   }

//   Future<void> _addBill() async {
//     if (_selectedBazarId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a bazar")),
//       );
//       return;
//     }

//     String product = _productController.text.trim();
//     int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
//     double price = double.tryParse(_priceController.text.trim()) ?? 0;
//     double discount = double.tryParse(_discountController.text.trim()) ?? 0;

//     if (product.isEmpty || price <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter product and valid price")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     // Insert product if not exists
//     final productId = await db.insert(
//       'products',
//       {'name': product},
//       conflictAlgorithm: ConflictAlgorithm.ignore,
//     );

//     final pid = productId > 0
//         ? productId
//         : (await db.query('products',
//                 where: 'name = ?', whereArgs: [product], limit: 1))
//             .first['id'] as int;

//     // Calculate total amount with discount
//     double totalAmount = (qty * price) - discount;

//     await db.insert('bills', {
//       'bazar_id': _selectedBazarId,
//       'product_id': pid,
//       'quantity': qty,
//       'price': price,
//       'total_amount': totalAmount,
//       'status': 'pending',
//       'date': DateTime.now().toIso8601String().substring(0, 10),
//     });

//     _productController.clear();
//     _qtyController.clear();
//     _priceController.clear();
//     _discountController.clear();

//     _fetchBills();
//   }

//   Future<void> _markPaid(int billId) async {
//     final db = await DBHelper().db;
//     await db.update(
//       'bills',
//       {'status': 'paid'},
//       where: 'id = ?',
//       whereArgs: [billId],
//     );
//     _fetchBills();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double pending = _total - _paid;

//     // Group bills by date
//     Map<String, List<Map<String, dynamic>>> groupedBills = {};
//     for (var bill in _bills) {
//       String date = bill['date'];
//       groupedBills.putIfAbsent(date, () => []);
//       groupedBills[date]!.add(bill);
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Billing")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Bazar dropdown
//             DropdownButtonFormField<int>(
//               value: _selectedBazarId,
//               items: _bazars.map((bazar) {
//                 return DropdownMenuItem<int>(
//                   value: bazar['id'] as int,
//                   child: Text(bazar['name'].toString()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedBazarId = value;
//                 });
//                 _fetchBills();
//               },
//               decoration: const InputDecoration(
//                 labelText: "Select Bazar",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Display totals
//             Text("Total: ₹$_total", style: const TextStyle(fontSize: 18)),
//             Text("Paid: ₹$_paid",
//                 style: const TextStyle(fontSize: 18, color: Colors.green)),
//             Text("Pending: ₹$pending",
//                 style: const TextStyle(fontSize: 18, color: Colors.red)),
//             const Divider(),

//             // Bill entry form
//             TextField(
//               controller: _productController,
//               decoration: const InputDecoration(
//                   labelText: "Product Name", border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _qtyController,
//               decoration: const InputDecoration(
//                   labelText: "Quantity", border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(
//                   labelText: "Price per Quantity",
//                   border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _discountController,
//               decoration: const InputDecoration(
//                   labelText: "Discount (optional)",
//                   border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _addBill,
//               child: const Text("Add Bill"),
//             ),
//             const Divider(),

//             // List of bills grouped by date
//             Expanded(
//               child: _bills.isEmpty
//                   ? const Center(child: Text("No bills yet"))
//                   : ListView(
//                       children: groupedBills.entries.map((entry) {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(entry.key,
//                                 style: const TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                             ...entry.value.map((bill) {
//                               return Card(
//                                 child: ListTile(
//                                   title: Text("${bill['product_name']}"),
//                                   subtitle: Text(
//                                       "Qty: ${bill['quantity']} x ₹${bill['price']}\nTotal: ₹${bill['total_amount']}"),
//                                   trailing: bill['status'] == 'pending'
//                                       ? ElevatedButton(
//                                           onPressed: () =>
//                                               _markPaid(bill['id'] as int),
//                                           child: const Text("Mark Paid"),
//                                         )
//                                       : const Icon(Icons.check_circle,
//                                           color: Colors.green),
//                                 ),
//                               );
//                             }),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class BillingScreen extends StatefulWidget {
//   final int bazarId;

//   const BillingScreen({super.key, required this.bazarId});

//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }

// class _BillingScreenState extends State<BillingScreen> {
//   final TextEditingController _productController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _discountController = TextEditingController();
//   final TextEditingController _costPriceController = TextEditingController();


//   List<Map<String, dynamic>> _bills = [];
//   List<Map<String, dynamic>> _bazars = [];

//   int? _selectedBazarId;
//   double _total = 0;
//   double _paid = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBazars();
//   }

//   Future<void> _fetchBazars() async {
//     final db = await DBHelper().db;
//     final bazars = await db.query("bazar");
//     setState(() {
//       _bazars = bazars;
//     });
//   }

//   Future<void> _fetchBills() async {
//     if (_selectedBazarId == null) return;

//     final db = await DBHelper().db;
//     final bills = await db.rawQuery('''
//       SELECT bills.*, products.name as product_name
//       FROM bills
//       LEFT JOIN products ON bills.product_id = products.id
//       WHERE bills.bazar_id = ?
//       ORDER BY bills.date DESC
//     ''', [_selectedBazarId]);

//     double total = 0;
//     double paid = 0;

//     for (var bill in bills) {
//       final amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == 'paid') {
//         paid += amount;
//       }
//     }

//     setState(() {
//       _bills = bills;
//       _total = total;
//       _paid = paid;
//     });
//   }

//   Future<void> _addBill() async {
//     if (_selectedBazarId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a bazar")),
//       );
//       return;
//     }

//     String product = _productController.text.trim();
//     int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
//     double price = double.tryParse(_priceController.text.trim()) ?? 0;
//     double discount = double.tryParse(_discountController.text.trim()) ?? 0;

//     if (product.isEmpty || price <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter product and valid price")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     // Insert product if not exists
//     final productId = await db.insert(
//       'products',
//       {'name': product},
//       conflictAlgorithm: ConflictAlgorithm.ignore,
//     );

//     final pid = productId > 0
//         ? productId
//         : (await db.query('products',
//                 where: 'name = ?', whereArgs: [product], limit: 1))
//             .first['id'] as int;

//     // Calculate total amount with discount
//     double totalAmount = (qty * price) - discount;

//     await db.insert('bills', {
//       'bazar_id': _selectedBazarId,
//       'product_id': pid,
//       'quantity': qty,
//       'price': price,
//       'total_amount': totalAmount,
//       'status': 'pending',
//       'date': DateTime.now().toIso8601String().substring(0, 10),
//     });

//     _productController.clear();
//     _qtyController.clear();
//     _priceController.clear();
//     _discountController.clear();

//     _fetchBills();
//   }

//   Future<void> _markPaid(int billId) async {
//     final db = await DBHelper().db;
//     await db.update(
//       'bills',
//       {'status': 'paid'},
//       where: 'id = ?',
//       whereArgs: [billId],
//     );
//     _fetchBills();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double pending = _total - _paid;

//     // Group bills by date
//     Map<String, List<Map<String, dynamic>>> groupedBills = {};
//     for (var bill in _bills) {
//       String date = bill['date'];
//       groupedBills.putIfAbsent(date, () => []);
//       groupedBills[date]!.add(bill);
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Billing"),
//         backgroundColor: Colors.lightBlue[700],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Bazar dropdown
//             DropdownButtonFormField<int>(
//               value: _selectedBazarId,
//               items: _bazars.map((bazar) {
//                 return DropdownMenuItem<int>(
//                   value: bazar['id'] as int,
//                   child: Text(bazar['name'].toString()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedBazarId = value;
//                 });
//                 _fetchBills();
//               },
//               decoration: InputDecoration(
//                 labelText: "Select Bazar",
//                 border: OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Display totals
//             Text("Total: ₹$_total",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text("Paid: ₹$_paid",
//                 style: const TextStyle(fontSize: 18, color: Colors.green)),
//             Text("Pending: ₹$pending",
//                 style: const TextStyle(fontSize: 18, color: Colors.red)),
//             const Divider(),

//             // Bill entry form
//             TextField(
//               controller: _productController,
//               decoration: InputDecoration(
//                 labelText: "Product Name",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _qtyController,
//               decoration: InputDecoration(
//                 labelText: "Quantity",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _priceController,
//               decoration: InputDecoration(
//                 labelText: "Price per Quantity",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _discountController,
//               decoration: InputDecoration(
//                 labelText: "Discount (optional)",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.lightBlue[700],
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: _addBill,
//               child: const Text("Add Bill"),
//             ),
//             const Divider(),

//             // List of bills grouped by date
//             Expanded(
//               child: _bills.isEmpty
//                   ? const Center(child: Text("No bills yet"))
//                   : ListView(
//                       children: groupedBills.entries.map((entry) {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(entry.key,
//                                 style: const TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                             ...entry.value.map((bill) {
//                               return Card(
//                                 color: Colors.lightBlue[50],
//                                 child: ListTile(
//                                   title: Text("${bill['product_name']}"),
//                                   subtitle: Text(
//                                       "Qty: ${bill['quantity']} x ₹${bill['price']}\nTotal: ₹${bill['total_amount']}"),
//                                   trailing: bill['status'] == 'pending'
//                                       ? ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.lightBlue[700],
//                                             foregroundColor: Colors.white,
//                                           ),
//                                           onPressed: () =>
//                                               _markPaid(bill['id'] as int),
//                                           child: const Text("Mark Paid"),
//                                         )
//                                       : const Icon(Icons.check_circle,
//                                           color: Colors.green),
//                                 ),
//                               );
//                             }),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BillingScreen extends StatefulWidget {
  final int bazarId;

  const BillingScreen({super.key, required this.bazarId});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController(); // new

  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _bazars = [];

  int? _selectedBazarId;
  double _total = 0;
  double _paid = 0;

  @override
  void initState() {
    super.initState();
    _fetchBazars();
  }

  Future<void> _fetchBazars() async {
    final db = await DBHelper().db;
    final bazars = await db.query("bazar");
    setState(() {
      _bazars = bazars;
    });
  }

  Future<void> _fetchBills() async {
    if (_selectedBazarId == null) return;

    final db = await DBHelper().db;
    final bills = await db.rawQuery('''
      SELECT bills.*, products.name as product_name
      FROM bills
      LEFT JOIN products ON bills.product_id = products.id
      WHERE bills.bazar_id = ?
      ORDER BY bills.date DESC
    ''', [_selectedBazarId]);

    double total = 0;
    double paid = 0;

    for (var bill in bills) {
      final amount = (bill['total_amount'] as num).toDouble();
      total += amount;
      if (bill['status'] == 'paid') {
        paid += amount;
      }
    }

    setState(() {
      _bills = bills;
      _total = total;
      _paid = paid;
    });
  }

  Future<void> _addBill() async {
    if (_selectedBazarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a bazar")),
      );
      return;
    }

    String product = _productController.text.trim();
    int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    double price = double.tryParse(_priceController.text.trim()) ?? 0;
    double costPrice = double.tryParse(_costPriceController.text.trim()) ?? 0; // new
    double discount = double.tryParse(_discountController.text.trim()) ?? 0;

    if (product.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter product and valid price")),
      );
      return;
    }

    final db = await DBHelper().db;

    // Insert product if not exists
    final productId = await db.insert(
      'products',
      {'name': product},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final pid = productId > 0
        ? productId
        : (await db.query('products',
                where: 'name = ?', whereArgs: [product], limit: 1))
            .first['id'] as int;

    // Calculate total amount with discount
    double totalAmount = (qty * price) - discount;

    await db.insert('bills', {
      'bazar_id': _selectedBazarId,
      'product_id': pid,
      'quantity': qty,
      'price': price,
      'cost_price': costPrice, // new
      'total_amount': totalAmount,
      'status': 'pending',
      'date': DateTime.now().toIso8601String().substring(0, 10),
    });

    _productController.clear();
    _qtyController.clear();
    _priceController.clear();
    _costPriceController.clear(); // new
    _discountController.clear();

    _fetchBills();
  }

  Future<void> _markPaid(int billId) async {
    final db = await DBHelper().db;
    await db.update(
      'bills',
      {'status': 'paid'},
      where: 'id = ?',
      whereArgs: [billId],
    );
    _fetchBills();
  }

  @override
  Widget build(BuildContext context) {
    double pending = _total - _paid;

    // Group bills by date
    Map<String, List<Map<String, dynamic>>> groupedBills = {};
    for (var bill in _bills) {
      String date = bill['date'];
      groupedBills.putIfAbsent(date, () => []);
      groupedBills[date]!.add(bill);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Billing"),
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedBazarId,
              items: _bazars.map((bazar) {
                return DropdownMenuItem<int>(
                  value: bazar['id'] as int,
                  child: Text(bazar['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBazarId = value;
                });
                _fetchBills();
              },
              decoration: InputDecoration(
                labelText: "Select Bazar",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text("Total: ₹$_total",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Paid: ₹$_paid",
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            Text("Pending: ₹$pending",
                style: const TextStyle(fontSize: 18, color: Colors.red)),
            const Divider(),

            // Bill entry form
            TextField(
              controller: _productController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _qtyController,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Selling Price per Quantity",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _costPriceController, // new
              decoration: InputDecoration(
                labelText: "Cost Price per Quantity",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: "Discount (optional)",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _addBill,
              child: const Text("Add Bill"),
            ),
            const Divider(),

            Expanded(
              child: _bills.isEmpty
                  ? const Center(child: Text("No bills yet"))
                  : ListView(
                      children: groupedBills.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ...entry.value.map((bill) {
                              double profit = ((bill['price'] ?? 0) - (bill['cost_price'] ?? 0)) *
                                  (bill['quantity'] ?? 0);
                              return Card(
                                color: Colors.lightBlue[50],
                                child: ListTile(
                                  title: Text("${bill['product_name']}"),
                                  subtitle: Text(
                                      "Qty: ${bill['quantity']} x ₹${bill['price']}\n"
                                      "Cost: ₹${bill['cost_price']}\n"
                                      "Profit: ₹$profit\n"
                                      "Total: ₹${bill['total_amount']}"),
                                  trailing: bill['status'] == 'pending'
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightBlue[700],
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () =>
                                              _markPaid(bill['id'] as int),
                                          child: const Text("Mark Paid"),
                                        )
                                      : const Icon(Icons.check_circle,
                                          color: Colors.green),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

