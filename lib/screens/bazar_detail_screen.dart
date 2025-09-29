// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class BazarDetailScreen extends StatefulWidget {
//   final int bazarId;
//   const BazarDetailScreen({super.key, required this.bazarId});

//   @override
//   State<BazarDetailScreen> createState() => _BazarDetailScreenState();
// }

// class _BazarDetailScreenState extends State<BazarDetailScreen> {
//   final TextEditingController _productController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _paidController = TextEditingController();

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

//     // Get bills for this bazar
//     final bills = await db.query(
//       'bills',
//       where: 'bazar_id = ?',
//       whereArgs: [widget.bazarId],
//       orderBy: "id DESC",
//     );

//     double total = 0;
//     double paid = 0;

//     for (var bill in bills) {
//       total += bill['total_amount'] as double;
//       if (bill['status'] == 'paid') {
//         paid += bill['total_amount'] as double;
//       }
//     }

//     setState(() {
//       _bills = bills;
//       _total = total;
//       _paid = paid;
//     });

//     // Update bazar summary in DB
//     await db.update(
//       'bazar',
//       {
//         'total_bill': total,
//         'paid': paid,
//       },
//       where: 'id = ?',
//       whereArgs: [widget.bazarId],
//     );
//   }

//   Future<void> _addBill() async {
//     String product = _productController.text.trim();
//     int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
//     double price = double.tryParse(_priceController.text.trim()) ?? 0;

//     if (product.isEmpty || price <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter product and valid price")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     // Insert into products if not exists
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

//     double totalAmount = qty * price;

//     await db.insert('bills', {
//       'bazar_id': widget.bazarId,
//       'product_id': pid,
//       'quantity': qty,
//       'price': price,
//       'total_amount': totalAmount,
//       'status': 'pending',
//       'date': DateTime.now().toIso8601String(),
//     });

//     _productController.clear();
//     _qtyController.clear();
//     _priceController.clear();

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
//     double unpaid = _total - _paid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Bazar Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text("Total: ₹$_total", style: const TextStyle(fontSize: 18)),
//             Text("Paid: ₹$_paid", style: const TextStyle(fontSize: 18)),
//             Text("Unpaid: ₹$unpaid", style: const TextStyle(fontSize: 18)),
//             const Divider(),
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
//             ElevatedButton(
//               onPressed: _addBill,
//               child: const Text("Add Product"),
//             ),
//             const Divider(),
//             Expanded(
//               child: _bills.isEmpty
//                   ? const Center(child: Text("No products added yet"))
//                   : ListView.builder(
//                       itemCount: _bills.length,
//                       itemBuilder: (context, index) {
//                         final bill = _bills[index];
//                         return Card(
//                           child: ListTile(
//                             title: Text("Product ID: ${bill['product_id']}"),
//                             subtitle: Text(
//                                 "Qty: ${bill['quantity']} x ₹${bill['price']}"),
//                             trailing: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text("Total: ₹${bill['total_amount']}"),
//                                 Text("Status: ${bill['status']}"),
//                               ],
//                             ),
//                             onTap: () => _markPaid(bill['id']),
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
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class BazarDetailScreen extends StatefulWidget {
//   final int bazarId;
//   const BazarDetailScreen({super.key, required this.bazarId});

//   @override
//   State<BazarDetailScreen> createState() => _BazarDetailScreenState();
// }

// class _BazarDetailScreenState extends State<BazarDetailScreen> {
//   final TextEditingController _productController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();

//   List<Map<String, dynamic>> _bills = [];
//   double _total = 0;
//   double _paid = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBills();
//   }
// Future<void> _fetchBills() async {
//   final db = await DBHelper().db;

//   final bills = await db.rawQuery('''
//     SELECT bills.*, products.name as product_name
//     FROM bills
//     LEFT JOIN products ON bills.product_id = products.id
//     WHERE bills.bazar_id = ?
//     ORDER BY bills.date DESC
//   ''', [widget.bazarId]);

//   double total = 0;
//   double paid = 0;

//   for (var bill in bills) {
//     final amount = (bill['total_amount'] as num).toDouble();
//     total += amount;
//     if (bill['status'] == 'paid') {
//       paid += amount;
//     }
//   }

//   setState(() {
//     _bills = bills;
//     _total = total;
//     _paid = paid;
//   });

//   await db.update(
//     'bazar',
//     {
//       'total_bill': total,
//       'paid': paid,
//     },
//     where: 'id = ?',
//     whereArgs: [widget.bazarId],
//   );
// }

//   // Future<void> _fetchBills() async {
//   //   final db = await DBHelper().db;

//   //   final bills = await db.query(
//   //     'bills',
//   //     where: 'bazar_id = ?',
//   //     whereArgs: [widget.bazarId],
//   //     orderBy: "date DESC",
//   //   );

//   //   double total = 0;
//   //   double paid = 0;

//   //   for (var bill in bills) {
//   //     final amount = (bill['total_amount'] as num).toDouble();
//   //     total += amount;
//   //     if (bill['status'] == 'paid') {
//   //       paid += amount;
//   //     }
//   //   }

//   //   setState(() {
//   //     _bills = bills;
//   //     _total = total;
//   //     _paid = paid;
//   //   });

//   //   await db.update(
//   //     'bazar',
//   //     {
//   //       'total_bill': total,
//   //       'paid': paid,
//   //     },
//   //     where: 'id = ?',
//   //     whereArgs: [widget.bazarId],
//   //   );
//   // }

//   Future<void> _addBill() async {
//     String product = _productController.text.trim();
//     int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
//     double price = double.tryParse(_priceController.text.trim()) ?? 0;

//     if (product.isEmpty || price <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter product and valid price")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     // Insert into products if not exists
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

//     double totalAmount = qty * price;

//     await db.insert('bills', {
//       'bazar_id': widget.bazarId,
//       'product_id': pid,
//       'quantity': qty,
//       'price': price,
//       'total_amount': totalAmount,
//       'status': 'pending',
//       'date': DateTime.now().toIso8601String().substring(0, 10), // yyyy-MM-dd
//     });

//     _productController.clear();
//     _qtyController.clear();
//     _priceController.clear();

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
//       appBar: AppBar(title: const Text("Bazar Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text("Total: ₹$_total", style: const TextStyle(fontSize: 18)),
//             Text("Paid: ₹$_paid",
//                 style: const TextStyle(fontSize: 18, color: Colors.green)),
//             Text("pending: ₹$pending",
//                 style: const TextStyle(fontSize: 18, color: Colors.red)),
//             const Divider(),
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
//             ElevatedButton(
//               onPressed: _addBill,
//               child: const Text("Add Product"),
//             ),
//             const Divider(),
//             Expanded(
//               child: _bills.isEmpty
//                   ? const Center(child: Text("No products added yet"))
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
//                                   title: Text("${bill['product_name'] ?? 'Product'}"),
//                                   subtitle: Text(
//                                       "Qty: ${bill['quantity']} x ₹${bill['price']}"),
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



import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BazarDetailScreen extends StatefulWidget {
  final int bazarId;
  const BazarDetailScreen({super.key, required this.bazarId});

  @override
  State<BazarDetailScreen> createState() => _BazarDetailScreenState();
}

class _BazarDetailScreenState extends State<BazarDetailScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<Map<String, dynamic>> _bills = [];
  double _total = 0;
  double _paid = 0;

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    final db = await DBHelper().db;

    final bills = await db.rawQuery('''
      SELECT bills.*, products.name as product_name
      FROM bills
      LEFT JOIN products ON bills.product_id = products.id
      WHERE bills.bazar_id = ?
      ORDER BY bills.date DESC
    ''', [widget.bazarId]);

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

    await db.update(
      'bazar',
      {
        'total_bill': total,
        'paid': paid,
      },
      where: 'id = ?',
      whereArgs: [widget.bazarId],
    );
  }

  Future<void> _addBill() async {
    String product = _productController.text.trim();
    int qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    double price = double.tryParse(_priceController.text.trim()) ?? 0;

    if (product.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Enter product and valid price"),
          backgroundColor: Colors.blueAccent,
        ),
      );
      return;
    }

    final db = await DBHelper().db;

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

    double totalAmount = qty * price;

    await db.insert('bills', {
      'bazar_id': widget.bazarId,
      'product_id': pid,
      'quantity': qty,
      'price': price,
      'total_amount': totalAmount,
      'status': 'pending',
      'date': DateTime.now().toIso8601String().substring(0, 10),
    });

    _productController.clear();
    _qtyController.clear();
    _priceController.clear();

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

    Map<String, List<Map<String, dynamic>>> groupedBills = {};
    for (var bill in _bills) {
      String date = bill['date'];
      if (!groupedBills.containsKey(date)) {
        groupedBills[date] = [];
      }
      groupedBills[date]!.add(bill);
    }

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text("Bazar Details"),
        backgroundColor: Colors.blueAccent, // Azure appbar
        foregroundColor: Colors.white, // White text
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Total: ₹$_total", style: const TextStyle(fontSize: 18)),
            Text("Paid: ₹$_paid",
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            Text("Pending: ₹$pending",
                style: const TextStyle(fontSize: 18, color: Colors.red)),
            const Divider(),
            TextField(
              controller: _productController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Price per Quantity",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _addBill,
              child: const Text("Add Product"),
            ),
            const Divider(),
            Expanded(
              child: _bills.isEmpty
                  ? const Center(
                      child: Text(
                        "No products added yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView(
                      children: groupedBills.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            ...entry.value.map((bill) {
                              return Card(
                                color: Colors.blue[50], // Light azure
                                child: ListTile(
                                  title: Text(
                                    "${bill['product_name'] ?? 'Product'}",
                                    style:
                                        const TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    "Qty: ${bill['quantity']} x ₹${bill['price']}",
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                  trailing: bill['status'] == 'pending'
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () =>
                                              _markPaid(bill['id']),
                                          child: const Text("Mark Paid"),
                                        )
                                      : const Icon(Icons.check_circle,
                                          color: Colors.green),
                                ),
                              );
                            }),
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
