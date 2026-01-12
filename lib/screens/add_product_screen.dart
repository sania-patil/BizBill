// import 'package:flutter/material.dart';
// import '../db/db_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   Future<void> _saveProduct() async {
//     String name = _nameController.text.trim();
//     String description = _descriptionController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Product name is required")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     await db.insert(
//       'products',
//       {
//         'name': name,
//         'description': description,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Product added successfully")),
//     );

//     _nameController.clear();
//     _descriptionController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Product"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: "Product Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: "Description",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: _saveProduct,
//               child: const Text("Save Product"),
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

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   List<Map<String, dynamic>> _products = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   // Future<void> _fetchProducts() async {
//   //   final db = await DBHelper().db;
//   //   final data = await db.query('products', orderBy: "id DESC");
//   //   setState(() {
//   //     _products = data;
//   //   });
//   // }
//   Future<void> _fetchProducts() async {
//   final db = await DBHelper().db;

//   // One row per product name (latest id desc)
//   final data = await db.rawQuery('''
//     SELECT MIN(id) AS id, name, MAX(description) AS description
//     FROM products
//     GROUP BY name
//     ORDER BY id DESC
//   ''');

//   setState(() {
//     _products = data;
//   });
// }


//   Future<void> _saveProduct() async {
//     String name = _nameController.text.trim();
//     String description = _descriptionController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Product name is required")),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     await db.insert(
//       'products',
//       {
//         'name': name,
//         'description': description,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Product added successfully")),
//     );

//     _nameController.clear();
//     _descriptionController.clear();

//     _fetchProducts(); // refresh list
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Product"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: "Product Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: "Description",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: _saveProduct,
//               child: const Text("Save Product"),
//             ),
//             const SizedBox(height: 20),
//             const Divider(),
//             Expanded(
//               child: _products.isEmpty
//                   ? const Center(child: Text("No products added yet"))
//                   : ListView.builder(
//                       itemCount: _products.length,
//                       itemBuilder: (context, index) {
//                         final product = _products[index];
//                         return Card(
//                           child: ListTile(
//                             title: Text(product['name']),
//                             subtitle: Text(product['description'] ?? ''),
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

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   List<Map<String, dynamic>> _products = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     final db = await DBHelper().db;

//     final data = await db.rawQuery('''
//       SELECT MIN(id) AS id, name, MAX(description) AS description
//       FROM products
//       GROUP BY name
//       ORDER BY id DESC
//     ''');

//     setState(() {
//       _products = data;
//     });
//   }

//   Future<void> _saveProduct() async {
//     String name = _nameController.text.trim();
//     String description = _descriptionController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Product name is required"),
//           backgroundColor: Colors.blueAccent, // Azure snackbar
//         ),
//       );
//       return;
//     }

//     final db = await DBHelper().db;

//     await db.insert(
//       'products',
//       {
//         'name': name,
//         'description': description,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("Product added successfully"),
//         backgroundColor: Colors.blueAccent, // Azure snackbar
//       ),
//     );

//     _nameController.clear();
//     _descriptionController.clear();

//     _fetchProducts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // White background
//       appBar: AppBar(
//         title: const Text("Add Product"),
//         backgroundColor: Colors.blueAccent, // Azure AppBar
//         foregroundColor: Colors.white, // White text
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: "Product Name",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blueAccent, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: "Description",
//                 border: const OutlineInputBorder(),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blueAccent, width: 2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent, // Azure
//                 foregroundColor: Colors.white, // White text
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: _saveProduct,
//               child: const Text("Save Product"),
//             ),
//             const SizedBox(height: 20),
//             const Divider(),
//             Expanded(
//               child: _products.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No products added yet",
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: _products.length,
//                       itemBuilder: (context, index) {
//                         final product = _products[index];
//                         return Card(
//                           color: Colors.blue[50], // Light azure card
//                           child: ListTile(
//                             title: Text(
//                               product['name'],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             subtitle: Text(
//                               product['description'] ?? '',
//                               style: const TextStyle(color: Colors.black87),
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


import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final db = await DBHelper().db;

    final data = await db.rawQuery('''
      SELECT MIN(id) AS id, name, MAX(description) AS description
      FROM products
      GROUP BY name
      ORDER BY id DESC
    ''');

    setState(() {
      _products = data;
    });
  }

  Future<void> _saveProduct() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Product name is required"),
          backgroundColor: Colors.blueAccent, // Azure snackbar
        ),
      );
      return;
    }

    final db = await DBHelper().db;

    await db.insert(
      'products',
      {
        'name': name,
        'description': description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Product added successfully"),
        backgroundColor: Colors.blueAccent, // Azure snackbar
      ),
    );

    _nameController.clear();
    _descriptionController.clear();

    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.blueAccent, // Azure AppBar
        foregroundColor: Colors.white, // White text
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Azure
                foregroundColor: Colors.white, // White text
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveProduct,
              child: const Text("Save Product"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: _products.isEmpty
                  ? const Center(
                      child: Text(
                        "No products added yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          color: Colors.blue[50], // Light azure card
                          child: ListTile(
                            title: Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              product['description'] ?? '',
                              style: const TextStyle(color: Colors.black87),
                            ),
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
