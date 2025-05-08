import 'package:flutter/material.dart';
import 'package:school_calendar_app_v3/screens/home_screen.dart';
import 'package:school_calendar_app_v3/screens/settings_screen.dart';

// Screens
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

  // 2) Initializes off-day data
  OffDays.initializeOffDays();

  // 3) Builds the full schedule
  final fullSchedule = FullSchedule();

  // 4) Creates and assigns rotational days
  final rotationalSchedule = RotationalSchedule();
  fullSchedule.assignRotationalDays(rotationalSchedule);

  // 5) Creates sample events
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
      rotationalDay: 1, 
    ),
    EventModel(
      name: 'Art Club',
      date: '2025-09-04',
      eventType: 'Club',
      recurrenceType: RecurrenceType.WEEKDAY,
      startTime: '14:00',
      endTime: '15:00',
      color: 'Green',
      weekDay: 1, 
    ),
  ];

  // 6) Processes events (assign them to the appropriate days in the schedule)
  final processor = ScheduleProcessor(fullSchedule: fullSchedule, events: events);
  processor.assignEventsToSchedule();

  // 7) Launchs the Flutter app
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
          selectedDate: DateTime.now(),
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