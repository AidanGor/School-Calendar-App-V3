import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // from flutterfire configure
// import 'package:firebase_auth/firebase_auth.dart';

// Import your newly created screens:
// import 'package:school_calendar_app_v3/screens/auth_gate.dart';    // <---
import 'package:school_calendar_app_v3/screens/home_screen.dart';

// Import your screens:
import 'package:school_calendar_app_v3/screens/weekly_calendar_screen.dart';
import 'package:school_calendar_app_v3/screens/monthly_calendar_screen.dart';
import 'package:school_calendar_app_v3/screens/daily_calendar_screen.dart';
import 'package:school_calendar_app_v3/screens/yearly_calendar_screen.dart';

// Models
import 'package:school_calendar_app_v3/models/off_days.dart';
import 'package:school_calendar_app_v3/models/full_schedule.dart';
import 'package:school_calendar_app_v3/models/rotational_schedule.dart';
import 'package:school_calendar_app_v3/models/event_model.dart';
import 'package:school_calendar_app_v3/models/schedule_processor.dart';

/// A helper method if you need to find the nearest Sunday before today's date.
DateTime findThisWeeksSunday() {
  final now = DateTime.now();
  var current = DateTime(now.year, now.month, now.day);
  while (current.weekday != DateTime.sunday) {
    current = current.subtract(const Duration(days: 1));
  }
  return current;
}

Future<void> main() async {
  // 1) Required for async calls before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2) Initialize Firebase using your generated firebase_options.dart
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // 3) Initialize off-day data
  OffDays.initializeOffDays();

  // 4) Build the full schedule
  final fullSchedule = FullSchedule();

  // 5) Create and assign rotational days
  final rotationalSchedule = RotationalSchedule();
  fullSchedule.assignRotationalDays(rotationalSchedule);

  // 6) Create sample events
  final events = <EventModel>[
    EventModel(
      name: 'Opening Day',
      date: '2025-09-04',
      eventType: 'Special',
      recurrenceType: RecurrenceType.NONE,
      startTime: '09:00',
      endTime: '10:00',
      color: 'Blue',
    ),
    EventModel(
      name: 'Math Class',
      date: '2025-09-04',
      eventType: 'Class',
      recurrenceType: RecurrenceType.ROTATIONAL,
      startTime: '10:00',
      endTime: '11:00',
      color: 'Red',
      rotationalDay: 1, // Rotational Day 1
    ),
    EventModel(
      name: 'Art Club',
      date: '2025-09-04',
      eventType: 'Club',
      recurrenceType: RecurrenceType.WEEKDAY,
      startTime: '14:00',
      endTime: '15:00',
      color: 'Green',
      weekDay: 1, // Monday
    ),
  ];

  // 7) Process events (assign them to the appropriate days in the schedule)
  final processor = ScheduleProcessor(fullSchedule: fullSchedule, events: events);
  processor.assignEventsToSchedule();

  // 8) Launch the Flutter app
  runApp(MyApp(fullSchedule: fullSchedule));
}

class MyApp extends StatelessWidget {
  final FullSchedule fullSchedule;

  const MyApp({super.key, required this.fullSchedule});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Calendar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/week',
      routes: {
        '/day': (context) => DayCalendarScreen(
          fullSchedule: fullSchedule,
          selectedDate: DateTime.now(), // Or pass a real date
        ),
        '/week': (context) => WeeklyCalendarScreen(
          fullSchedule: fullSchedule,
          startOfWeek: DateTime.utc(2025, 8, 31),
        ),
        '/month': (context) => MonthlyCalendarScreen(
          fullSchedule: fullSchedule,
        ),
        '/year': (context) => YearCalendarScreen(
          fullSchedule: fullSchedule,
          year: 2025,
        ),
      }
    );
  }
}