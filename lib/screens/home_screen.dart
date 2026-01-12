// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("SHREE GANESH PRODUCTS"),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//            ElevatedButton(
//               onPressed: () {
//                 int bazarId = 1; // Replace with the actual bazar ID you want
//                 Navigator.pushNamed(
//                   context,
//                   '/billing',
//                   arguments: bazarId, // Pass the bazarId here
//                 );
//               },
//               child: const Text("Billing"),
//             ),

//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/reports');
//               },
//               child: const Text("Reports"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/settings');
//               },
//               child: const Text("Settings"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/add_products');
//               },
//               child: const Text("Add Products"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/add_bazars');
//               },
//               child: const Text("Bazars"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text("SHREE GANESH PRODUCTS"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Azure (AppBar color)
        foregroundColor: Colors.white, // Text/Icon color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Billing Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Azure
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                int bazarId = 1;
                Navigator.pushNamed(
                  context,
                  '/billing',
                  arguments: bazarId,
                );
              },
              child: const Text("Billing"),
            ),

            const SizedBox(height: 20),
            // Reports Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/reports');
              },
              child: const Text("Reports"),
            ),

            const SizedBox(height: 20),
            // Settings Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text("Settings"),
            ),

            const SizedBox(height: 20),
            // Add Products Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/add_products');
              },
              child: const Text("Add Products"),
            ),

            const SizedBox(height: 20),
            // Bazars Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/add_bazars');
              },
              child: const Text("Bazars"),
            ),
             const SizedBox(height: 20),
            // Add Products Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/expenses');
              },
              child: const Text("Expenses"),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   final String title;
//   final int businessId;

//   const HomeScreen({
//     super.key,
//     required this.title,
//     required this.businessId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/billing',
//                   arguments: businessId, // pass businessId
//                 );
//               },
//               child: const Text("Billing"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/reports',
//                   arguments: businessId, // pass businessId
//                 );
//               },
//               child: const Text("Reports"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/settings',
//                   arguments: businessId, // pass businessId
//                 );
//               },
//               child: const Text("Settings"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/add_products',
//                   arguments: businessId, // pass businessId
//                 );
//               },
//               child: const Text("Add Products"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/add_bazars',
//                   arguments: businessId, // pass businessId
//                 );
//               },
//               child: const Text("Bazars"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
