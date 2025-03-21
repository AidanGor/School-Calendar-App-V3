// import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class RotationalScheduleSetupScreen extends StatefulWidget {
//   const RotationalScheduleSetupScreen({Key? key}) : super(key: key);

//   @override
//   State<RotationalScheduleSetupScreen> createState() => _RotationalScheduleSetupScreenState();
// }

// class _RotationalScheduleSetupScreenState extends State<RotationalScheduleSetupScreen> {
//   // We'll store a list of classes for each day, e.g. day 1..7
//   final Map<int, List<ClassBlock>> dayClasses = {
//     1: [],
//     2: [],
//     3: [],
//     4: [],
//     5: [],
//     6: [],
//     7: [],
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Set Up Rotational Schedule"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             for (int day = 1; day <= 7; day++)
//               _buildDaySection(day),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.check),
//         onPressed: _saveScheduleAndGenerateEvents,
//       ),
//     );
//   }

//   Widget _buildDaySection(int day) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: ExpansionTile(
//         title: Text("Day $day"),
//         children: [
//           // Show existing classes
//           for (int i = 0; i < dayClasses[day]!.length; i++)
//             ListTile(
//               title: Text(dayClasses[day]![i].name),
//               subtitle: Text("${dayClasses[day]![i].startTime} - ${dayClasses[day]![i].endTime}"),
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () {
//                   setState(() {
//                     dayClasses[day]!.removeAt(i);
//                   });
//                 },
//               ),
//             ),
//           // Add new class button
//           TextButton.icon(
//             icon: const Icon(Icons.add),
//             label: const Text("Add Class"),
//             onPressed: () => _showAddClassDialog(day),
//           )
//         ],
//       ),
//     );
//   }

//   Future<void> _showAddClassDialog(int day) async {
//     final nameController = TextEditingController();
//     final startController = TextEditingController(text: "09:00");
//     final endController = TextEditingController(text: "10:00");

//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           title: Text("Add Class for Day $day"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(controller: nameController, decoration: const InputDecoration(labelText: "Class Name")),
//               TextField(controller: startController, decoration: const InputDecoration(labelText: "Start Time (HH:MM)")),
//               TextField(controller: endController, decoration: const InputDecoration(labelText: "End Time (HH:MM)")),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
//             TextButton(
//               onPressed: () {
//                 final block = ClassBlock(
//                   name: nameController.text.trim(),
//                   startTime: startController.text.trim(),
//                   endTime: endController.text.trim(),
//                 );
//                 setState(() {
//                   dayClasses[day]!.add(block);
//                 });
//                 Navigator.pop(ctx);
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Future<void> _saveScheduleAndGenerateEvents() async {
//   //   final uid = FirebaseAuth.instance.currentUser!.uid;
//   //   final firestore = FirebaseFirestore.instance;

//   //   // 1) Save rotationalSchedule in Firestore
//   //   for (int day = 1; day <= 7; day++) {
//   //     final classesMap = dayClasses[day]!.map((cls) => {
//   //       "name": cls.name,
//   //       "start": cls.startTime,
//   //       "end": cls.endTime,
//   //     }).toList();

//   //     await firestore
//   //       .collection("users")
//   //       .doc(uid)
//   //       .collection("rotationalSchedule")
//   //       .doc(day.toString())
//   //       .set({
//   //         "classes": classesMap,
//   //       });
//   //   }

//     // 2) Generate events for the semester
//     final startDate = DateTime(2025, 8, 28);
//     final endDate = DateTime(2025, 12, 15);
//     DateTime current = startDate;
//     // Suppose day 1 is 8/28, day 2 is 8/29, etc. Adjust logic if needed:
//     int rotationIndex = 1; 

//     // while (!current.isAfter(endDate)) {
//     //   // skip weekends if your rotation doesn't meet weekends
//     //   if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
//     //     final doc = await firestore
//     //       .collection("users")
//     //       .doc(uid)
//     //       .collection("rotationalSchedule")
//     //       .doc(rotationIndex.toString())
//     //       .get();

//     //     if (doc.exists) {
//     //       final data = doc.data()!;
//     //       final classes = data["classes"] as List<dynamic>;
//     //       for (var cls in classes) {
//     //         await firestore
//     //           .collection("users")
//     //           .doc(uid)
//     //           .collection("events")
//     //           .add({
//     //             "name": cls["name"],
//     //             "date": DateFormat('yyyy-MM-dd').format(current),
//     //             "startTime": cls["start"],
//     //             "endTime": cls["end"],
//     //             "color": "Blue",
//     //             "recurrenceType": "ROTATIONAL",
//     //             "createdAt": FieldValue.serverTimestamp(),
//     //           });
//     //       }
//     //     }
//     //   }

//       current = current.add(const Duration(days: 1));
//       rotationIndex = (rotationIndex % 7) + 1; // cycle 1..7
//     }

//     // 3) Navigate back or to your HomeScreen
//     Navigator.pop(context); // pop the schedule screen
//   }
// }

// class ClassBlock {
//   final String name;
//   final String startTime;
//   final String endTime;

//   ClassBlock({
//     required this.name,
//     required this.startTime,
//     required this.endTime,
//   });
// }