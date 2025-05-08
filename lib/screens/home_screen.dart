import 'package:flutter/material.dart';
import 'weekly_calendar_screen.dart';

import '../models/full_schedule.dart';


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


  @override
  Widget build(BuildContext context) {
    return WeeklyCalendarScreen(
      fullSchedule: widget.fullSchedule,
      startOfWeek: DateTime.utc(2025, 8, 31),
    );
  }
}