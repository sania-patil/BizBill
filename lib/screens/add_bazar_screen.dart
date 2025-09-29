// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'bazar_detail_screen.dart';

// class AddBazarScreen extends StatefulWidget {
//   const AddBazarScreen({super.key});

//   @override
//   State<AddBazarScreen> createState() => _AddBazarScreenState();
// }

// class _AddBazarScreenState extends State<AddBazarScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();

//   List<Map<String, dynamic>> _bazars = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchBazars();
//   }

//   // Future<void> _fetchBazars() async {
//   //   final db = await DBHelper().db;
//   //   final data = await db.query('bazar', orderBy: "id DESC");
//   //   setState(() {
//   //     _bazars = data;
//   //   });
//   // }
//   Future<void> _fetchBazars() async {
//   final db = await DBHelper().db;

//   // Get all bazars
//   final bazars = await db.query('bazar', orderBy: "id DESC");

//   // For each bazar, calculate total and paid from bills
//   List<Map<String, dynamic>> result = [];
//   for (var bazar in bazars) {
//     final bills = await db.query(
//       'bills',
//       where: 'bazar_id = ?',
//       whereArgs: [bazar['id']],
//     );

//     double total = 0;
//     double paid = 0;
//     for (var bill in bills) {
//       double amount = (bill['total_amount'] as num).toDouble();
//       total += amount;
//       if (bill['status'] == 'paid') {
//         paid += amount;
//       }
//     }

//     result.add({
//       ...bazar,
//       'total_bill': total,
//       'paid': paid,
//     });
//   }

//   setState(() {
//     _bazars = result;
//   });
// }


//   Future<void> _saveBazar() async {
//     String name = _nameController.text.trim();
//     String contact = _contactController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Bazar name is required")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     await db.insert(
//       'bazar',
//       {
//         'name': name,
//         'contact': contact,
//         'total_bill': 0,
//         'paid': 0,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Bazar added successfully")),
//     );

//     _nameController.clear();
//     _contactController.clear();

//     _fetchBazars(); // refresh list
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Bazar"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: "Bazar Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _contactController,
//               decoration: const InputDecoration(
//                 labelText: "Contact (optional)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: _saveBazar,
//               child: const Text("Save Bazar"),
//             ),
//             const SizedBox(height: 20),
//             const Divider(),
//             Expanded(
//               child: _bazars.isEmpty
//                   ? const Center(child: Text("No bazars added yet"))
//                   : ListView.builder(
//                       itemCount: _bazars.length,
//                       itemBuilder: (context, index) {
//                         final bazar = _bazars[index];
//                         return Card(
//                           child: ListTile(
//                             title: Text(bazar['name']),
//                             subtitle: Text(bazar['contact'] ?? ''),
//                             trailing: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text("Total: ₹${bazar['total_bill']}"),
//                                 Text("Paid: ₹${bazar['paid']}"),
//                               ],
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => BazarDetailScreen(bazarId: bazar['id']),
//                                 ),
//                               );
//                             },
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



import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'bazar_detail_screen.dart';

class AddBazarScreen extends StatefulWidget {
  const AddBazarScreen({super.key});

  @override
  State<AddBazarScreen> createState() => _AddBazarScreenState();
}

class _AddBazarScreenState extends State<AddBazarScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  List<Map<String, dynamic>> _bazars = [];

  @override
  void initState() {
    super.initState();
    _fetchBazars();
  }

  Future<void> _fetchBazars() async {
    final db = await DBHelper().db;

    final bazars = await db.query('bazar', orderBy: "id DESC");

    List<Map<String, dynamic>> result = [];
    for (var bazar in bazars) {
      final bills = await db.query(
        'bills',
        where: 'bazar_id = ?',
        whereArgs: [bazar['id']],
      );

      double total = 0;
      double paid = 0;
      for (var bill in bills) {
        double amount = (bill['total_amount'] as num).toDouble();
        total += amount;
        if (bill['status'] == 'paid') {
          paid += amount;
        }
      }

      result.add({
        ...bazar,
        'total_bill': total,
        'paid': paid,
      });
    }

    setState(() {
      _bazars = result;
    });
  }

  Future<void> _saveBazar() async {
    String name = _nameController.text.trim();
    String contact = _contactController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bazar name is required")),
      );
      return;
    }

    final db = await DBHelper().db;

    await db.insert(
      'bazar',
      {
        'name': name,
        'contact': contact,
        'total_bill': 0,
        'paid': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bazar added successfully")),
    );

    _nameController.clear();
    _contactController.clear();

    _fetchBazars(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text("Add Bazar"),
        backgroundColor: Colors.blueAccent, // Azure appbar
        foregroundColor: Colors.white, // White text
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Bazar Name",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: "Contact (optional)",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Azure
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveBazar,
              child: const Text("Save Bazar"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: _bazars.isEmpty
                  ? const Center(
                      child: Text(
                        "No bazars added yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _bazars.length,
                      itemBuilder: (context, index) {
                        final bazar = _bazars[index];
                        return Card(
                          color: Colors.blue[50], // Light azure card background
                          child: ListTile(
                            title: Text(
                              bazar['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              bazar['contact'] ?? '',
                              style: const TextStyle(color: Colors.black87),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Total: ₹${bazar['total_bill']}",
                                    style: const TextStyle(color: Colors.black)),
                                Text("Paid: ₹${bazar['paid']}",
                                    style: const TextStyle(color: Colors.green)),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BazarDetailScreen(bazarId: bazar['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
