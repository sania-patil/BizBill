// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static final DBHelper _instance = DBHelper._internal();
//   factory DBHelper() => _instance;
//   DBHelper._internal();

//   static Database? _db;

//   Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   Future<Database> initDB() async {
//     String path = join(await getDatabasesPath(), "bazar_app.db");
//     return await openDatabase(
//       path,
//       version: 2,
//       onCreate: (db, version) async {
//         // Create Products table
//         await db.execute('''
//         CREATE TABLE products (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           name TEXT,
//           amount REAL,
//           status TEXT DEFAULT 'unpaid',
//           date TEXT DEFAULT CURRENT_DATE
//         )
//       ''');


//         // Create Bazar table
//         await db.execute('''
//           CREATE TABLE bazar (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT NOT NULL,
//             contact TEXT,
//             total_bill REAL DEFAULT 0,
//             paid REAL DEFAULT 0
//           )
//         ''');

//         await db.execute('''
//             CREATE TABLE expenses (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               category TEXT,         -- e.g., Food, Travelling
//               amount REAL,
//               date TEXT              -- stored as yyyy-MM-dd
//             )
//         ''');


//         // Create Bills table
//         await db.execute('''
//           CREATE TABLE bills (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             bazar_id INTEGER,
//             product_id INTEGER,
//             quantity INTEGER,
//             price REAL,
//             total_amount REAL,
//             status TEXT CHECK(status IN ('pending', 'paid')) NOT NULL DEFAULT 'pending',
//             date TEXT,
//             FOREIGN KEY (bazar_id) REFERENCES bazar (id),
//             FOREIGN KEY (product_id) REFERENCES products (id)
//           )
//         ''');
//       },
//     );
//   }
// }


// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static final DBHelper _instance = DBHelper._internal();
//   factory DBHelper() => _instance;
//   DBHelper._internal();

//   static Database? _db;

//   Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   Future<Database> initDB() async {
//     String path = join(await getDatabasesPath(), "bazar_app.db");
//     return await openDatabase(
//       path,
//       version: 2, // updated from 1 to 2
//       onCreate: (db, version) async {
//         // Create Products table
//         await db.execute('''
//           CREATE TABLE products (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             amount REAL,
//             status TEXT DEFAULT 'unpaid',
//             date TEXT DEFAULT CURRENT_DATE
//           )
//         ''');

//         // Create Bazar table
//         await db.execute('''
//           CREATE TABLE bazar (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT NOT NULL,
//             contact TEXT,
//             total_bill REAL DEFAULT 0,
//             paid REAL DEFAULT 0
//           )
//         ''');

//         // Create Expenses table
//         await db.execute('''
//           CREATE TABLE expenses (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             category TEXT,         
//             amount REAL,
//             date TEXT
//           )
//         ''');

//         // Create Bills table
//         // onCreate
// await db.execute('''
//   CREATE TABLE bills (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     bazar_id INTEGER,
//     product_id INTEGER,
//     quantity INTEGER,
//     price REAL,         -- selling price
//     cost_price REAL,    -- new: cost price
//     total_amount REAL,
//     status TEXT CHECK(status IN ('pending', 'paid')) NOT NULL DEFAULT 'pending',
//     date TEXT,
//     FOREIGN KEY (bazar_id) REFERENCES bazar (id),
//     FOREIGN KEY (product_id) REFERENCES products (id)
//   )
// ''');

// // onUpgrade
//     if (oldVersion < 3) {  // bump version to 3
//       await db.execute('''
//         ALTER TABLE bills ADD COLUMN cost_price REAL DEFAULT 0
//       ''');
//     }

//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         // If upgrading from version 1 to 2, create expenses table
//         if (oldVersion < 2) {
//           await db.execute('''
//             CREATE TABLE IF NOT EXISTS expenses (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               category TEXT,         
//               amount REAL,
//               date TEXT
//             )
//           ''');
//         }
//       },
//     );
//   }
// }


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), "bazar_app.db");

    return await openDatabase(
      path,
      version: 3, // bump to 3 for cost_price
      onCreate: (db, version) async {
        // Create Products table
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            amount REAL,
            status TEXT DEFAULT 'unpaid',
            date TEXT DEFAULT CURRENT_DATE
          )
        ''');

        // Create Bazar table
        await db.execute('''
          CREATE TABLE bazar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact TEXT,
            total_bill REAL DEFAULT 0,
            paid REAL DEFAULT 0
          )
        ''');

        // Create Expenses table
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            amount REAL,
            date TEXT
          )
        ''');

        // Create Bills table with cost_price
        await db.execute('''
          CREATE TABLE bills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bazar_id INTEGER,
            product_id INTEGER,
            quantity INTEGER,
            price REAL,       -- selling price
            cost_price REAL DEFAULT 0,  -- cost price
            total_amount REAL,
            status TEXT CHECK(status IN ('pending', 'paid')) NOT NULL DEFAULT 'pending',
            date TEXT,
            FOREIGN KEY (bazar_id) REFERENCES bazar (id),
            FOREIGN KEY (product_id) REFERENCES products (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Upgrade to version 2: create expenses table if missing
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS expenses (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT,
              amount REAL,
              date TEXT
            )
          ''');
        }

        // Upgrade to version 3: add cost_price column to bills
        if (oldVersion < 3) {
          await db.execute('''
            ALTER TABLE bills ADD COLUMN cost_price REAL DEFAULT 0
          ''');
        }
      },
    );
  }
}
