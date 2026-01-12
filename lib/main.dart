// import 'package:flutter/material.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // 👈 for desktop
// import 'db/db_helper.dart';
// import 'screens/home_screen.dart';
// import 'screens/add_product_screen.dart'; 
// import 'screens/add_bazar_screen.dart';
// import '/screens/billing_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 👇 Initialize ffi for desktop (Windows, Linux, macOS)
//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;

//   // initialize the database
//   await DBHelper().db;

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Bazar App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const HomeScreen(),
//        routes: {
//         '/add_products': (context) => const AddProductScreen(), // 👈 register
//         '/add_bazars': (context) => const AddBazarScreen(),
//         // '/billing': (context) => const BillingScreen(),
//         // In main.dart
//         '/billing': (context) {
//           final args = ModalRoute.of(context)!.settings.arguments as int;
//           return BillingScreen(bazarId: args);
//         },

//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // 👈 for desktop
import 'db/db_helper.dart';
import 'screens/home_screen.dart';
import 'screens/add_product_screen.dart'; 
import 'screens/add_bazar_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/expenses.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Initialize ffi for desktop (Windows, Linux, macOS)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // initialize the database
  await DBHelper().db;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bazar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        '/add_products': (context) => const AddProductScreen(),
        '/add_bazars': (context) => const AddBazarScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/expenses': (context) => const ExpensesScreen(),

      },
      // 👇 Use onGenerateRoute for routes that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/billing') {
          final args = settings.arguments as int; // bazarId is passed as int
          return MaterialPageRoute(
            builder: (context) => BillingScreen(bazarId: args),
          );
        }
        return null;
      },
    );
  }
}
