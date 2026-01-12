// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _selectedMonth;
//   Map<String, double> _totals = {
//     "paid": 0,
//     "pending": 0,
//     "total": 0,
//   };
//   List<Map<String, dynamic>> _productWise = [];



//   @override
//   void initState() {
//     super.initState();
//     _fetchReport(); // default: all months
//   }

//   Future<void> _fetchReport() async {
//     final db = await DBHelper().db;

//     String whereClause = "";
//     List<String> whereArgs = [];

//     if (_selectedMonth != null) {
//       whereClause = "strftime('%m', date) = ?";
//       whereArgs = [_selectedMonth!];
//     }

//     // Fetch all bills (filtered by month if selected)
//     final bills = await db.query(
//       "bills",
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );

//     double paid = 0, pending = 0, total = 0;

//     // Group product-wise totals
//     Map<int, Map<String, dynamic>> productTotals = {};

//     for (var bill in bills) {
//       double amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == "paid") {
//         paid += amount;
//       } else {
//         pending += amount;
//       }

//       int productId = bill['product_id'] as int;
//       productTotals.putIfAbsent(productId, () => {
//         "product_id": productId,
//         "product_name": "",
//         "paid": 0.0,
//         "pending": 0.0,
//         "total": 0.0,
//       });

//       if (bill['status'] == "paid") {
//         productTotals[productId]!["paid"] += amount;
//       } else {
//         productTotals[productId]!["pending"] += amount;
//       }
//       productTotals[productId]!["total"] += amount;
//     }

//     // Fetch product names
//     for (var entry in productTotals.entries) {
//       final product = await db.query(
//         "products",
//         where: "id = ?",
//         whereArgs: [entry.key],
//         limit: 1,
//       );
//       if (product.isNotEmpty) {
//         entry.value["product_name"] = product.first["name"];
//       }
//     }

//     setState(() {
//       _totals = {
//         "paid": paid,
//         "pending": pending,
//         "total": total,
//       };
//       _productWise = productTotals.values.toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Reports")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Month dropdown
//             DropdownButton<String>(
//               hint: const Text("Select Month"),
//               value: _selectedMonth,
//               items: _months.map((m) {
//                 return DropdownMenuItem(
//                   value: m,
//                   child: Text("Month $m"),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedMonth = val;
//                 });
//                 _fetchReport();
//               },
//             ),
//             const SizedBox(height: 20),

//             // Totals
//             Card(
//               child: ListTile(
//                 title: const Text("Overall Totals"),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Total: ₹${_totals['total']}"),
//                     Text("Paid: ₹${_totals['paid']}"),
//                     Text("Pending: ₹${_totals['pending']}"),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Product-wise report
//             const Text("Product-wise Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             Expanded(
//               child: _productWise.isEmpty
//                   ? const Center(child: Text("No data"))
//                   : ListView.builder(
//                       itemCount: _productWise.length,
//                       itemBuilder: (context, index) {
//                         final p = _productWise[index];
//                         return Card(
//                           child: ListTile(
//                             title: Text(p["product_name"]),
//                             subtitle: Text(
//                               "Total: ₹${p['total']} | Paid: ₹${p['paid']} | Pending: ₹${p['pending']}",
//                             ),
//                           ),
//                         );
//                       },
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

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _selectedMonth;
//   Map<String, double> _totals = {"paid": 0, "pending": 0, "total": 0};
//   Map<String, double> _overallTotals = {"paid": 0, "pending": 0, "total": 0};
//   List<Map<String, dynamic>> _productWise = [];

//   final List<String> _months = [
//     "01","02","03","04","05","06","07","08","09","10","11","12"
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchReport();
//   }

//   /// Helper for safe currency formatting
//   String formatAmount(dynamic value) {
//     if (value == null) return "₹0.00";
//     return "₹${(value as num).toStringAsFixed(2)}";
//   }

// Future<void> _fetchReport() async {
//   final db = await DBHelper().db;

//   String whereClause = "";
//   List<String> whereArgs = [];

//   if (_selectedMonth != null) {
//     whereClause = "strftime('%m', bills.date) = ?";
//     whereArgs = [_selectedMonth!];
//   }

//   /// -------- Month-wise bills --------
//   final bills = await db.query(
//     "bills",
//     where: whereClause.isNotEmpty ? whereClause : null,
//     whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//   );

//   double paid = 0, pending = 0, total = 0;
//   Map<int, Map<String, dynamic>> productTotals = {};

//   for (var bill in bills) {
//     double amount = (bill['total_amount'] ?? 0).toDouble();
//     int quantity = (bill['quantity'] ?? 0) as int;
//     double price = (bill['price'] ?? 0).toDouble();

//     total += amount;
//     if (bill['status'] == "paid") {
//       paid += amount;
//     } else {
//       pending += amount;
//     }

//     int productId = (bill['product_id'] ?? 0) as int;
//     if (productId == 0) continue;

//     productTotals.putIfAbsent(productId, () => {
//       "product_id": productId,
//       "product_name": "",
//       "quantity": 0,
//       "selling_price": 0.0,
//       "cost_price": 0.0,
//       "profit": 0.0,
//       "total": 0.0,
//       "paid": 0.0,
//       "pending": 0.0,
//     });

//     productTotals[productId]!["quantity"] += quantity;
//     productTotals[productId]!["selling_price"] = price; // latest price
//     productTotals[productId]!["total"] += amount;

//     if (bill['status'] == "paid") {
//       productTotals[productId]!["paid"] += amount;
//     } else {
//       productTotals[productId]!["pending"] += amount;
//     }
//   }

//   // Fetch product names & cost price
//   for (var entry in productTotals.entries) {
//     final product = await db.query(
//       "products",
//       where: "id = ?",
//       whereArgs: [entry.key],
//       limit: 1,
//     );
//     if (product.isNotEmpty) {
//       entry.value["product_name"] = product.first["name"] ?? "";
//       entry.value["cost_price"] = (product.first["amount"] ?? 0).toDouble();

//       // calculate profit = (selling - cost) × quantity
//       entry.value["profit"] =
//           ((entry.value["selling_price"] ?? 0) -
//            (entry.value["cost_price"] ?? 0)) *
//           (entry.value["quantity"] ?? 0);
//     }
//   }

//   /// -------- Overall Totals --------
//   final allBills = await db.query("bills");
//   double overallPaid = 0, overallPending = 0, overallTotal = 0;
//   for (var bill in allBills) {
//     double amount = (bill['total_amount'] ?? 0).toDouble();
//     overallTotal += amount;
//     if (bill['status'] == "paid") {
//       overallPaid += amount;
//     } else {
//       overallPending += amount;
//     }
//   }

//   setState(() {
//     _totals = {"paid": paid, "pending": pending, "total": total};
//     _overallTotals = {
//       "paid": overallPaid,
//       "pending": overallPending,
//       "total": overallTotal
//     };
//     _productWise = productTotals.values.toList();
//   });
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Reports")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Month dropdown
//             DropdownButton<String>(
//               hint: const Text("Select Month"),
//               value: _selectedMonth,
//               items: _months.map((m) {
//                 return DropdownMenuItem(
//                   value: m,
//                   child: Text("Month $m"),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedMonth = val;
//                 });
//                 _fetchReport();
//               },
//             ),
//             const SizedBox(height: 20),

//             // Month-wise Totals
//             Card(
//               child: ListTile(
//                 title: const Text("Month-wise Totals"),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Total: ${formatAmount(_totals['total'])}"),
//                     Text("Paid: ${formatAmount(_totals['paid'])}"),
//                     Text("Pending: ${formatAmount(_totals['pending'])}"),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Overall Totals
//             Card(
//               color: Colors.blue.shade50,
//               child: ListTile(
//                 title: const Text("Overall Totals (Till Today)"),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Total: ${formatAmount(_overallTotals['total'])}"),
//                     Text("Paid: ${formatAmount(_overallTotals['paid'])}"),
//                     Text("Pending: ${formatAmount(_overallTotals['pending'])}"),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Product-wise report in table
//             const Text("Product-wise Report",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             Expanded(
//               child: _productWise.isEmpty
//                   ? const Center(child: Text("No data"))
//                   : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         border: TableBorder.all(color: Colors.grey.shade300),
//                         columns: const [
//                           DataColumn(label: Text("Product")),
//                           DataColumn(label: Text("Qty")),
//                           DataColumn(label: Text("Selling ₹")),
//                           DataColumn(label: Text("Cost ₹")),
//                           DataColumn(label: Text("Total ₹")),
//                           DataColumn(label: Text("Profit ₹")),
//                           DataColumn(label: Text("Paid ₹")),
//                           DataColumn(label: Text("Pending ₹")),
//                         ],
//                         rows: _productWise.map((p) {
//                           return DataRow(cells: [
//                             DataCell(Text(p["product_name"].toString())),
//                             DataCell(Text((p["quantity"] ?? 0).toString())),
//                             DataCell(Text(formatAmount(p["selling_price"]))),
//                             DataCell(Text(formatAmount(p["cost_price"]))),
//                             DataCell(Text(formatAmount(p["total"]))),
//                             DataCell(Text(
//                               formatAmount(p["profit"]),
//                               style: TextStyle(
//                                 color: (p["profit"] ?? 0) >= 0
//                                     ? Colors.green
//                                     : Colors.red,
//                               ),
//                             )),
//                             DataCell(Text(formatAmount(p["paid"]))),
//                             DataCell(Text(formatAmount(p["pending"]))),
//                           ]);
//                         }).toList(),
//                       ),
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

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _selectedMonth;
//   Map<String, double> _totals = {
//     "paid": 0,
//     "pending": 0,
//     "total": 0,
//   };
//   List<Map<String, dynamic>> _productWise = [];

//   // ✅ Months list
//   final List<Map<String, String>> _months = [
//     {"value": "01", "label": "January"},
//     {"value": "02", "label": "February"},
//     {"value": "03", "label": "March"},
//     {"value": "04", "label": "April"},
//     {"value": "05", "label": "May"},
//     {"value": "06", "label": "June"},
//     {"value": "07", "label": "July"},
//     {"value": "08", "label": "August"},
//     {"value": "09", "label": "September"},
//     {"value": "10", "label": "October"},
//     {"value": "11", "label": "November"},
//     {"value": "12", "label": "December"},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchReport(); // default: all months
//   }

//   Future<void> _fetchReport() async {
//     final db = await DBHelper().db;

//     String whereClause = "";
//     List<String> whereArgs = [];

//     if (_selectedMonth != null) {
//       whereClause = "strftime('%m', date) = ?";
//       whereArgs = [_selectedMonth!];
//     }

//     // Fetch all bills (filtered by month if selected)
//     final bills = await db.query(
//       "bills",
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );

//     double paid = 0, pending = 0, total = 0;

//     // Group product-wise totals
//     Map<int, Map<String, dynamic>> productTotals = {};

//     for (var bill in bills) {
//       double amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == "paid") {
//         paid += amount;
//       } else {
//         pending += amount;
//       }

//       int productId = bill['product_id'] as int;
//       productTotals.putIfAbsent(productId, () => {
//             "product_id": productId,
//             "product_name": "",
//             "paid": 0.0,
//             "pending": 0.0,
//             "total": 0.0,
//           });

//       if (bill['status'] == "paid") {
//         productTotals[productId]!["paid"] += amount;
//       } else {
//         productTotals[productId]!["pending"] += amount;
//       }
//       productTotals[productId]!["total"] += amount;
//     }

//     // Fetch product names
//     for (var entry in productTotals.entries) {
//       final product = await db.query(
//         "products",
//         where: "id = ?",
//         whereArgs: [entry.key],
//         limit: 1,
//       );
//       if (product.isNotEmpty) {
//         entry.value["product_name"] = product.first["name"];
//       }
//     }

//     setState(() {
//       _totals = {
//         "paid": paid,
//         "pending": pending,
//         "total": total,
//       };
//       _productWise = productTotals.values.toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Reports")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // ✅ Fixed Month dropdown
//             DropdownButton<String>(
//               hint: const Text("Select Month"),
//               value: _selectedMonth,
//               items: _months.map((m) {
//                 return DropdownMenuItem(
//                   value: m["value"], // month number (01, 02...)
//                   child: Text(m["label"]!), // month name
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedMonth = val;
//                 });
//                 _fetchReport();
//               },
//             ),
//             const SizedBox(height: 20),

//             // Totals
//             Card(
//               child: ListTile(
//                 title: const Text("Overall Totals"),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Total: ₹${_totals['total']}"),
//                     Text("Paid: ₹${_totals['paid']}"),
//                     Text("Pending: ₹${_totals['pending']}"),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Product-wise report
//             const Text("Product-wise Report",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             Expanded(
//               child: _productWise.isEmpty
//                   ? const Center(child: Text("No data"))
//                   : ListView.builder(
//                       itemCount: _productWise.length,
//                       itemBuilder: (context, index) {
//                         final p = _productWise[index];
//                         return Card(
//                           child: ListTile(
//                             title: Text(p["product_name"]),
//                             subtitle: Text(
//                               "Total: ₹${p['total']} | Paid: ₹${p['paid']} | Pending: ₹${p['pending']}",
//                             ),
//                           ),
//                         );
//                       },
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

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _selectedMonth;
//   Map<String, double> _totals = {
//     "paid": 0,
//     "pending": 0,
//     "total": 0,
//   };
//   List<Map<String, dynamic>> _productWise = [];

//   // ✅ Months list
//   final List<Map<String, String>> _months = [
//     {"value": "01", "label": "January"},
//     {"value": "02", "label": "February"},
//     {"value": "03", "label": "March"},
//     {"value": "04", "label": "April"},
//     {"value": "05", "label": "May"},
//     {"value": "06", "label": "June"},
//     {"value": "07", "label": "July"},
//     {"value": "08", "label": "August"},
//     {"value": "09", "label": "September"},
//     {"value": "10", "label": "October"},
//     {"value": "11", "label": "November"},
//     {"value": "12", "label": "December"},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchReport(); // default: all months
//   }

//   Future<void> _fetchReport() async {
//     final db = await DBHelper().db;

//     String whereClause = "";
//     List<String> whereArgs = [];

//     if (_selectedMonth != null) {
//       whereClause = "strftime('%m', date) = ?";
//       whereArgs = [_selectedMonth!];
//     }

//     // Fetch all bills (filtered by month if selected)
//     final bills = await db.query(
//       "bills",
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );

//     double paid = 0, pending = 0, total = 0;

//     // Group product-wise totals
//     Map<int, Map<String, dynamic>> productTotals = {};

//     for (var bill in bills) {
//       double amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == "paid") {
//         paid += amount;
//       } else {
//         pending += amount;
//       }

//       int productId = bill['product_id'] as int;
//       productTotals.putIfAbsent(productId, () => {
//             "product_id": productId,
//             "product_name": "",
//             "paid": 0.0,
//             "pending": 0.0,
//             "total": 0.0,
//           });

//       if (bill['status'] == "paid") {
//         productTotals[productId]!["paid"] += amount;
//       } else {
//         productTotals[productId]!["pending"] += amount;
//       }
//       productTotals[productId]!["total"] += amount;
//     }

//     // Fetch product names
//     for (var entry in productTotals.entries) {
//       final product = await db.query(
//         "products",
//         where: "id = ?",
//         whereArgs: [entry.key],
//         limit: 1,
//       );
//       if (product.isNotEmpty) {
//         entry.value["product_name"] = product.first["name"];
//       }
//     }

//     setState(() {
//       _totals = {
//         "paid": paid,
//         "pending": pending,
//         "total": total,
//       };
//       _productWise = productTotals.values.toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Reports"),
//         backgroundColor: Colors.lightBlue[700],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // ✅ Month dropdown
//             DropdownButtonFormField<String>(
//               value: _selectedMonth,
//               items: _months.map((m) {
//                 return DropdownMenuItem(
//                   value: m["value"], // month number (01, 02...)
//                   child: Text(m["label"]!), // month name
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedMonth = val;
//                 });
//                 _fetchReport();
//               },
//               decoration: InputDecoration(
//                 labelText: "Select Month",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Totals card
//             Card(
//               color: Colors.lightBlue[50],
//               child: ListTile(
//                 title: const Text("Overall Totals",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Total: ₹${_totals['total']}",
//                         style: const TextStyle(fontSize: 16)),
//                     Text("Paid: ₹${_totals['paid']}",
//                         style: TextStyle(
//                             fontSize: 16, color: Colors.green.shade700)),
//                     Text("Pending: ₹${_totals['pending']}",
//                         style: TextStyle(
//                             fontSize: 16, color: Colors.red.shade700)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Product-wise report
//             const Text("Product-wise Report",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             Expanded(
//               child: _productWise.isEmpty
//                   ? const Center(child: Text("No data"))
//                   : ListView.builder(
//                       itemCount: _productWise.length,
//                       itemBuilder: (context, index) {
//                         final p = _productWise[index];
//                         return Card(
//                           color: Colors.lightBlue[50],
//                           child: ListTile(
//                             title: Text(
//                               p["product_name"],
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                             subtitle: Text(
//                               "Total: ₹${p['total']} | Paid: ₹${p['paid']} | Pending: ₹${p['pending']}",
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         );
//                       },
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

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _selectedMonth;
//   Map<String, double> _monthTotals = {"paid": 0, "pending": 0, "total": 0, "profit": 0};
//   Map<String, double> _overallTotals = {"paid": 0, "pending": 0, "total": 0, "profit": 0};
//   List<Map<String, dynamic>> _productWise = [];

//   final List<Map<String, String>> _months = [
//     {"value": "01", "label": "January"},
//     {"value": "02", "label": "February"},
//     {"value": "03", "label": "March"},
//     {"value": "04", "label": "April"},
//     {"value": "05", "label": "May"},
//     {"value": "06", "label": "June"},
//     {"value": "07", "label": "July"},
//     {"value": "08", "label": "August"},
//     {"value": "09", "label": "September"},
//     {"value": "10", "label": "October"},
//     {"value": "11", "label": "November"},
//     {"value": "12", "label": "December"},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchReport();
//   }

//   Future<void> _fetchReport() async {
//   final db = await DBHelper().db;

//   // Overall totals
//   final allBills = await db.query("bills");
//   double oPaid = 0, oPending = 0, oTotal = 0, oProfit = 0;

//   for (var bill in allBills) {
//     double amt = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
//     double cost = (bill['cost_price'] as num?)?.toDouble() ?? 0.0;
//     double price = (bill['price'] as num?)?.toDouble() ?? 0.0;
//     int qty = (bill['quantity'] as num?)?.toInt() ?? 0;
//     double profit = (price - cost) * qty;

//     oTotal += amt;
//     oProfit += profit;

//     if (bill['status'] == "paid") {
//       oPaid += amt;
//     } else {
//       oPending += amt;
//     }
//   }

//   // Subtract overall expenses
//   final allExpenses = await db.query("expenses");
//   double totalExpense = 0;
//   for (var exp in allExpenses) {
//     totalExpense += (exp['amount'] as num?)?.toDouble() ?? 0.0;
//   }
//   oProfit -= totalExpense; // net overall profit

//   // Month filter
//   String whereClause = "";
//   List<String> whereArgs = [];
//   if (_selectedMonth != null) {
//     whereClause = "strftime('%m', date) = ?";
//     whereArgs = [_selectedMonth!];
//   }

//   final bills = await db.query(
//     "bills",
//     where: whereClause.isNotEmpty ? whereClause : null,
//     whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//   );

//   double mPaid = 0, mPending = 0, mTotal = 0, mProfit = 0;
//   Map<int, Map<String, dynamic>> productTotals = {};

//   for (var bill in bills) {
//     double amount = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
//     double cost = (bill['cost_price'] as num?)?.toDouble() ?? 0.0;
//     double price = (bill['price'] as num?)?.toDouble() ?? 0.0;
//     int qty = (bill['quantity'] as num?)?.toInt() ?? 0;
//     double profit = (price - cost) * qty;

//     mTotal += amount;
//     mProfit += profit;
//     if (bill['status'] == "paid") {
//       mPaid += amount;
//     } else {
//       mPending += amount;
//     }

//     int productId = (bill['product_id'] as num?)?.toInt() ?? 0;
//     productTotals.putIfAbsent(productId, () => {
//           "product_id": productId,
//           "product_name": "",
//           "paid": 0.0,
//           "pending": 0.0,
//           "total": 0.0,
//           "profit": 0.0,
//         });

//     if (bill['status'] == "paid") {
//       productTotals[productId]!["paid"] += amount;
//     } else {
//       productTotals[productId]!["pending"] += amount;
//     }
//     productTotals[productId]!["total"] += amount;
//     productTotals[productId]!["profit"] += profit;
//   }

//   // Subtract monthly expenses
//   double monthExpense = 0;
//   final monthExpenses = await db.query(
//     "expenses",
//     where: whereClause.isNotEmpty ? whereClause : null,
//     whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//   );
//   for (var exp in monthExpenses) {
//     monthExpense += (exp['amount'] as num?)?.toDouble() ?? 0.0;
//   }
//   mProfit -= monthExpense; // net month profit

//   // Fetch product names
//   for (var entry in productTotals.entries) {
//     final product = await db.query(
//       "products",
//       where: "id = ?",
//       whereArgs: [entry.key],
//       limit: 1,
//     );
//     if (product.isNotEmpty) {
//       entry.value["product_name"] = product.first["name"];
//     }
//   }

//   setState(() {
//     _overallTotals = {
//       "paid": oPaid,
//       "pending": oPending,
//       "total": oTotal,
//       "profit": oProfit
//     };
//     _monthTotals = {
//       "paid": mPaid,
//       "pending": mPending,
//       "total": mTotal,
//       "profit": mProfit
//     };
//     _productWise = productTotals.values.toList();
//   });
// }



//   Widget _buildTotalsCard(String title, Map<String, double> totals) {
//     return Card(
//       color: Colors.lightBlue[50],
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 8),
//             Text("Total: ₹${totals['total']!.toStringAsFixed(2)}",
//                 style: const TextStyle(fontSize: 16)),
//             Text("Paid: ₹${totals['paid']!.toStringAsFixed(2)}",
//                 style: TextStyle(fontSize: 16, color: Colors.green.shade700)),
//             Text("Pending: ₹${totals['pending']!.toStringAsFixed(2)}",
//                 style: TextStyle(fontSize: 16, color: Colors.red.shade700)),
//             Text("Profit: ₹${totals['profit']!.toStringAsFixed(2)}",
//                 style: TextStyle(fontSize: 16, color: Colors.orange.shade800)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String monthLabel = _selectedMonth != null
//         ? _months
//             .firstWhere(
//                 (m) => m['value'] == _selectedMonth, orElse: () => {"label": "All"})
//             ['label']!
//         : "All";

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Reports"),
//         backgroundColor: Colors.lightBlue[700],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Month dropdown
//             DropdownButtonFormField<String>(
//               value: _selectedMonth,
//               items: _months.map((m) {
//                 return DropdownMenuItem(
//                   value: m["value"],
//                   child: Text(m["label"]!),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedMonth = val;
//                 });
//                 _fetchReport();
//               },
//               decoration: InputDecoration(
//                 labelText: "Select Month",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide:
//                       BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Month totals
//             _buildTotalsCard("$monthLabel Totals", _monthTotals),
//             const SizedBox(height: 10),

//             // Overall totals
//             _buildTotalsCard("Overall Totals", _overallTotals),
//             const SizedBox(height: 20),

//             // Product-wise report
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text("Product-wise Report",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 10),

//             Expanded(
//               child: _productWise.isEmpty
//                   ? const Center(child: Text("No data"))
//                   : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor:
//                             MaterialStateProperty.all(Colors.lightBlue[100]),
//                         border: TableBorder.all(color: Colors.grey.shade300),
//                         columns: const [
//                           DataColumn(label: Text("Product")),
//                           DataColumn(label: Text("Total")),
//                           DataColumn(label: Text("Paid")),
//                           DataColumn(label: Text("Pending")),
//                           DataColumn(label: Text("Profit")),
//                         ],
//                         rows: _productWise.map((p) {
//                           return DataRow(cells: [
//                             DataCell(Text(p["product_name"])),
//                             DataCell(Text("₹${(p['total'] as double).toStringAsFixed(2)}")),
//                             DataCell(Text("₹${(p['paid'] as double).toStringAsFixed(2)}")),
//                             DataCell(Text("₹${(p['pending'] as double).toStringAsFixed(2)}")),
//                             DataCell(Text("₹${(p['profit'] as double).toStringAsFixed(2)}")),
//                           ]);
//                         }).toList(),
//                       ),
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

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _selectedMonth;
//   Map<String, double> _monthTotals = {"paid": 0, "pending": 0, "total": 0, "profit": 0};
//   Map<String, double> _overallTotals = {"paid": 0, "pending": 0, "total": 0, "profit": 0};
//   List<Map<String, dynamic>> _productWise = [];
//   Map<String, Map<String, double>> _bazarWiseTotals = {}; // NEW

//   final List<Map<String, String>> _months = [
//     {"value": "01", "label": "January"},
//     {"value": "02", "label": "February"},
//     {"value": "03", "label": "March"},
//     {"value": "04", "label": "April"},
//     {"value": "05", "label": "May"},
//     {"value": "06", "label": "June"},
//     {"value": "07", "label": "July"},
//     {"value": "08", "label": "August"},
//     {"value": "09", "label": "September"},
//     {"value": "10", "label": "October"},
//     {"value": "11", "label": "November"},
//     {"value": "12", "label": "December"},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchReport();
//   }

//   Future<void> _fetchReport() async {
//     final db = await DBHelper().db;

//     // Overall totals
//     final allBills = await db.query("bills");
//     double oPaid = 0, oPending = 0, oTotal = 0, oProfit = 0;

//     for (var bill in allBills) {
//       double amt = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
//       double cost = (bill['cost_price'] as num?)?.toDouble() ?? 0.0;
//       double price = (bill['price'] as num?)?.toDouble() ?? 0.0;
//       int qty = (bill['quantity'] as num?)?.toInt() ?? 0;
//       double profit = (price - cost) * qty;

//       oTotal += amt;
//       oProfit += profit;

//       if (bill['status'] == "paid") {
//         oPaid += amt;
//       } else {
//         oPending += amt;
//       }
//     }

//     // Subtract overall expenses
//     final allExpenses = await db.query("expenses");
//     double totalExpense = 0;
//     for (var exp in allExpenses) {
//       totalExpense += (exp['amount'] as num?)?.toDouble() ?? 0.0;
//     }
//     oProfit -= totalExpense;

//     // Month filter
//     String whereClause = "";
//     List<String> whereArgs = [];
//     if (_selectedMonth != null) {
//       whereClause = "strftime('%m', bills.date) = ?";
//       whereArgs = [_selectedMonth!];
//     }

//     // Join bills with bazar
//     final bills = await db.rawQuery('''
//       SELECT bills.*, bazar.name AS bazar_name 
//       FROM bills 
//       LEFT JOIN bazar ON bills.bazar_id = bazar.id
//       ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}
//     ''', whereArgs);

//     double mPaid = 0, mPending = 0, mTotal = 0, mProfit = 0;
//     Map<int, Map<String, dynamic>> productTotals = {};
//     Map<String, Map<String, double>> bazarTotals = {}; // NEW

//     for (var bill in bills) {
//       double amount = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
//       double cost = (bill['cost_price'] as num?)?.toDouble() ?? 0.0;
//       double price = (bill['price'] as num?)?.toDouble() ?? 0.0;
//       int qty = (bill['quantity'] as num?)?.toInt() ?? 0;
//       double profit = (price - cost) * qty;

//       mTotal += amount;
//       mProfit += profit;
//       if (bill['status'] == "paid") {
//         mPaid += amount;
//       } else {
//         mPending += amount;
//       }

//       // ---- Product wise ----
//       int productId = (bill['product_id'] as num?)?.toInt() ?? 0;
//       productTotals.putIfAbsent(productId, () => {
//             "product_id": productId,
//             "product_name": "",
//             "paid": 0.0,
//             "pending": 0.0,
//             "total": 0.0,
//             "profit": 0.0,
//           });

//       if (bill['status'] == "paid") {
//         productTotals[productId]!["paid"] += amount;
//       } else {
//         productTotals[productId]!["pending"] += amount;
//       }
//       productTotals[productId]!["total"] += amount;
//       productTotals[productId]!["profit"] += profit;

//       // ---- Bazar wise ----
//       String bazarName = bill['bazar_name']?.toString() ?? "Unknown Bazar";
//       bazarTotals.putIfAbsent(bazarName, () => {
//             "paid": 0.0,
//             "pending": 0.0,
//             "total": 0.0,
//             "profit": 0.0,
//           });

//       if (bill['status'] == "paid") {
//   bazarTotals[bazarName]!["paid"] =
//       (bazarTotals[bazarName]!["paid"] as double? ?? 0) + amount;
// } else {
//   bazarTotals[bazarName]!["pending"] =
//       (bazarTotals[bazarName]!["pending"] as double? ?? 0) + amount;
// }

// bazarTotals[bazarName]!["total"] =
//     (bazarTotals[bazarName]!["total"] as double? ?? 0) + amount;

// bazarTotals[bazarName]!["profit"] =
//     (bazarTotals[bazarName]!["profit"] as double? ?? 0) + profit;


//     // Subtract monthly expenses
//     double monthExpense = 0;
//     final monthExpenses = await db.query(
//       "expenses",
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );
//     for (var exp in monthExpenses) {
//       monthExpense += (exp['amount'] as num?)?.toDouble() ?? 0.0;
//     }
//     mProfit -= monthExpense;

//     // Fetch product names
//     for (var entry in productTotals.entries) {
//       final product = await db.query(
//         "products",
//         where: "id = ?",
//         whereArgs: [entry.key],
//         limit: 1,
//       );
//       if (product.isNotEmpty) {
//         entry.value["product_name"] = product.first["name"];
//       }
//     }

//     setState(() {
//       _overallTotals = {"paid": oPaid, "pending": oPending, "total": oTotal, "profit": oProfit};
//       _monthTotals = {"paid": mPaid, "pending": mPending, "total": mTotal, "profit": mProfit};
//       _productWise = productTotals.values.toList();
//       _bazarWiseTotals = bazarTotals; // ✅ save bazar-wise
//     });
//   }
//   }
//   Widget _buildTotalsCard(String title, Map<String, double> totals) {
//     return Card(
//       color: Colors.lightBlue[50],
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 8),
//             Text("Total: ₹${totals['total']!.toStringAsFixed(2)}",
//                 style: const TextStyle(fontSize: 16)),
//             Text("Paid: ₹${totals['paid']!.toStringAsFixed(2)}",
//                 style: TextStyle(fontSize: 16, color: Colors.green.shade700)),
//             Text("Pending: ₹${totals['pending']!.toStringAsFixed(2)}",
//                 style: TextStyle(fontSize: 16, color: Colors.red.shade700)),
//             Text("Profit: ₹${totals['profit']!.toStringAsFixed(2)}",
//                 style: TextStyle(fontSize: 16, color: Colors.orange.shade800)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String monthLabel = _selectedMonth != null
//         ? _months.firstWhere((m) => m['value'] == _selectedMonth, orElse: () => {"label": "All"})['label']!
//         : "All";

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Reports"),
//         backgroundColor: Colors.lightBlue[700],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: _selectedMonth,
//               items: _months.map((m) {
//                 return DropdownMenuItem(
//                   value: m["value"],
//                   child: Text(m["label"]!),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedMonth = val;
//                 });
//                 _fetchReport();
//               },
//               decoration: InputDecoration(
//                 labelText: "Select Month",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             _buildTotalsCard("$monthLabel Totals", _monthTotals),
//             const SizedBox(height: 10),
//             _buildTotalsCard("Overall Totals", _overallTotals),
//             const SizedBox(height: 20),

//             // ---- Bazar wise report ----
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text("Bazar-wise Report",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView(
//                 children: _bazarWiseTotals.entries.map((entry) {
//                   return _buildTotalsCard(entry.key, entry.value);
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ---- Product wise report ----
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text("Product-wise Report",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: _productWise.isEmpty
//                   ? const Center(child: Text("No data"))
//                   : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor: MaterialStateProperty.all(Colors.lightBlue[100]),
//                         border: TableBorder.all(color: Colors.grey.shade300),
//                         columns: const [
//                           DataColumn(label: Text("Product")),
//                           DataColumn(label: Text("Total")),
//                           DataColumn(label: Text("Paid")),
//                           DataColumn(label: Text("Pending")),
//                           DataColumn(label: Text("Profit")),
//                         ],
//                         rows: _productWise.map((p) {
//                           return DataRow(cells: [
//                             DataCell(Text(p["product_name"])),
//                             DataCell(Text("₹${(p['total'] as double).toStringAsFixed(2)}")),
//                             DataCell(Text("₹${(p['paid'] as double).toStringAsFixed(2)}")),
//                             DataCell(Text("₹${(p['pending'] as double).toStringAsFixed(2)}")),
//                             DataCell(Text("₹${(p['profit'] as double).toStringAsFixed(2)}")),
//                           ]);
//                         }).toList(),
//                       ),
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

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedMonth;
  Map<String, double> _monthTotals = {"paid": 0, "pending": 0, "total": 0, "profit": 0};
  Map<String, double> _overallTotals = {"paid": 0, "pending": 0, "total": 0, "profit": 0};
  List<Map<String, dynamic>> _productWise = [];
  Map<String, Map<String, double>> _bazarWiseTotals = {};

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

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    final db = await DBHelper().db;

    // ---------- Overall totals ----------
    final allBills = await db.query("bills");
    double oPaid = 0, oPending = 0, oTotal = 0, oProfit = 0;

    for (var bill in allBills) {
      double amt = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
      double cost = (bill['cost_price'] as num?)?.toDouble() ?? 0.0;
      double price = (bill['price'] as num?)?.toDouble() ?? 0.0;
      int qty = (bill['quantity'] as num?)?.toInt() ?? 0;
      double profit = (price - cost) * qty;

      oTotal += amt;
      oProfit += profit;

      if (bill['status'] == "paid") {
        oPaid += amt;
      } else {
        oPending += amt;
      }
    }

    // subtract overall expenses
    final allExpenses = await db.query("expenses");
    for (var exp in allExpenses) {
      oProfit -= (exp['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // ---------- Month filter ----------
    String whereClause = "";
    List<String> whereArgs = [];
    if (_selectedMonth != null) {
      whereClause = "strftime('%m', bills.date) = ?";
      whereArgs = [_selectedMonth!];
    }

    final bills = await db.rawQuery('''
      SELECT bills.*, bazar.name AS bazar_name 
      FROM bills 
      LEFT JOIN bazar ON bills.bazar_id = bazar.id
      ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}
    ''', whereArgs);

    double mPaid = 0, mPending = 0, mTotal = 0, mProfit = 0;
    Map<int, Map<String, dynamic>> productTotals = {};
    Map<String, Map<String, double>> bazarTotals = {};

    for (var bill in bills) {
      double amount = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
      double cost = (bill['cost_price'] as num?)?.toDouble() ?? 0.0;
      double price = (bill['price'] as num?)?.toDouble() ?? 0.0;
      int qty = (bill['quantity'] as num?)?.toInt() ?? 0;
      double profit = (price - cost) * qty;

      mTotal += amount;
      mProfit += profit;
      if (bill['status'] == "paid") {
        mPaid += amount;
      } else {
        mPending += amount;
      }

      // product-wise
      int productId = (bill['product_id'] as num?)?.toInt() ?? 0;
      productTotals.putIfAbsent(productId, () => {
            "product_id": productId,
            "product_name": "",
            "paid": 0.0,
            "pending": 0.0,
            "total": 0.0,
            "profit": 0.0,
          });
      if (bill['status'] == "paid") {
        productTotals[productId]!["paid"] =
            (productTotals[productId]!["paid"] as double) + amount;
      } else {
        productTotals[productId]!["pending"] =
            (productTotals[productId]!["pending"] as double) + amount;
      }
      productTotals[productId]!["total"] =
          (productTotals[productId]!["total"] as double) + amount;
      productTotals[productId]!["profit"] =
          (productTotals[productId]!["profit"] as double) + profit;

      // bazar-wise
      String bazarName = bill['bazar_name']?.toString() ?? "Unknown Bazar";
      bazarTotals.putIfAbsent(bazarName, () => {
            "paid": 0.0,
            "pending": 0.0,
            "total": 0.0,
            "profit": 0.0,
          });
      if (bill['status'] == "paid") {
        bazarTotals[bazarName]!["paid"] =
            (bazarTotals[bazarName]!["paid"] as double) + amount;
      } else {
        bazarTotals[bazarName]!["pending"] =
            (bazarTotals[bazarName]!["pending"] as double) + amount;
      }
      bazarTotals[bazarName]!["total"] =
          (bazarTotals[bazarName]!["total"] as double) + amount;
      bazarTotals[bazarName]!["profit"] =
          (bazarTotals[bazarName]!["profit"] as double) + profit;
    }

    // subtract month expenses (👉 moved OUTSIDE loop)
    final monthExpenses = await db.query(
      "expenses",
      where: whereClause.isNotEmpty ? "strftime('%m', date) = ?" : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    for (var exp in monthExpenses) {
      mProfit -= (exp['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // fetch product names
    for (var entry in productTotals.entries) {
      final product = await db.query(
        "products",
        where: "id = ?",
        whereArgs: [entry.key],
        limit: 1,
      );
      if (product.isNotEmpty) {
        entry.value["product_name"] = product.first["name"];
      }
    }

    setState(() {
      _overallTotals = {"paid": oPaid, "pending": oPending, "total": oTotal, "profit": oProfit};
      _monthTotals = {"paid": mPaid, "pending": mPending, "total": mTotal, "profit": mProfit};
      _productWise = productTotals.values.toList();
      _bazarWiseTotals = bazarTotals;
    });
  }

  Widget _buildTotalsCard(String title, Map<String, double> totals) {
    return Card(
      color: Colors.lightBlue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Total: ₹${totals['total']!.toStringAsFixed(2)}"),
            Text("Paid: ₹${totals['paid']!.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.green.shade700)),
            Text("Pending: ₹${totals['pending']!.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.red.shade700)),
            Text("Profit: ₹${totals['profit']!.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.orange.shade800)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String monthLabel = _selectedMonth != null
        ? _months.firstWhere((m) => m['value'] == _selectedMonth, orElse: () => {"label": "All"})['label']!
        : "All";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(   // 👉 whole page scrollable
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              items: _months.map((m) {
                return DropdownMenuItem(
                  value: m["value"],
                  child: Text(m["label"]!),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedMonth = val);
                _fetchReport();
              },
              decoration: InputDecoration(
                labelText: "Select Month",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildTotalsCard("$monthLabel Totals", _monthTotals),
            const SizedBox(height: 10),
            _buildTotalsCard("Overall Totals", _overallTotals),
            const SizedBox(height: 20),

            const Text("Bazar-wise Report", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: _bazarWiseTotals.entries
                  .map((entry) => _buildTotalsCard(entry.key, entry.value))
                  .toList(),
            ),
            const SizedBox(height: 20),

            const Text("Product-wise Report", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _productWise.isEmpty
                ? const Text("No data")
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.lightBlue[100]),
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columns: const [
                        DataColumn(label: Text("Product")),
                        DataColumn(label: Text("Total")),
                        DataColumn(label: Text("Paid")),
                        DataColumn(label: Text("Pending")),
                        DataColumn(label: Text("Profit")),
                      ],
                      rows: _productWise.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(p["product_name"])),
                          DataCell(Text("₹${(p['total'] as double).toStringAsFixed(2)}")),
                          DataCell(Text("₹${(p['paid'] as double).toStringAsFixed(2)}")),
                          DataCell(Text("₹${(p['pending'] as double).toStringAsFixed(2)}")),
                          DataCell(Text("₹${(p['profit'] as double).toStringAsFixed(2)}")),
                        ]);
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
