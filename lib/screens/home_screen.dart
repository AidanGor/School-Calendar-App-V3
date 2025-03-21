import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import other screens if needed
// import 'rotational_schedule_setup_screen.dart';
import 'weekly_calendar_screen.dart';

import '../models/full_schedule.dart';

// 1) Add a constructor parameter for FullSchedule
class HomeScreen extends StatefulWidget {
  final FullSchedule fullSchedule;
  const HomeScreen({Key? key, required this.fullSchedule}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // _checkRotationalSchedule();
  }

  // Future<void> _checkRotationalSchedule() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return; // no user

  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('rotationalSchedule')
  //       .get();

  //   if (snapshot.docs.isEmpty) {
  //     // No schedule -> navigate to RotationalSetup
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const RotationalScheduleSetupScreen(),
  //         ),
  //       );
  //     });
  //   }
  //   // else the user has a schedule -> do nothing, just show weekly
  // }

  @override
  Widget build(BuildContext context) {
    return WeeklyCalendarScreen(
      fullSchedule: widget.fullSchedule,
      startOfWeek: DateTime.utc(2025, 8, 31),
    );
  }
}