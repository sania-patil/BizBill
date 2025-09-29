// import 'package:flutter/material.dart';
// import 'cleaning_dashboard.dart';  // create this file for cleaning dashboard
// import 'food_dashboard.dart';      // create this file for food dashboard

// class BusinessSelectionScreen extends StatelessWidget {
//   const BusinessSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Choose Business"),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(200, 50),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CleaningDashboard(businessId: 1),
//                   ),
//                 );
//               },
//               child: const Text("Cleaning Products"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(200, 50),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FoodDashboard(businessId: 2),
//                   ),
//                 );
//               },
//               child: const Text("Food Products"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
