import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/full_schedule.dart';
import '../models/day_model.dart';
import '../models/event_model.dart';

class DayCalendarScreen extends StatefulWidget {
  final FullSchedule fullSchedule;
  final DateTime selectedDate; // The day to display

  const DayCalendarScreen({
    Key? key,
    required this.fullSchedule,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<DayCalendarScreen> createState() => _DayCalendarScreenState();
}

class _DayCalendarScreenState extends State<DayCalendarScreen> {
  // For a day view, you might want to display hours 0..23 in a column,
  // or just a list of events for the day. We'll do a simple hour-based layout.
  final int startHour = 0;
  final int endHour = 23;

  DayModel? get dayData {
    // Find the matching DayModel in the schedule
    for (var week in widget.fullSchedule.returnSchedule()) {
      for (var d in week) {
        if (d.date.year == widget.selectedDate.year &&
            d.date.month == widget.selectedDate.month &&
            d.date.day == widget.selectedDate.day) {
          return d;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Day View: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}",
        ),
      ),
      body: Column(
        children: [
          _buildViewSelector(context),
          Expanded(
            child: _buildDayLayout(),
          ),
        ],
      ),
    );
  }

  // A row of buttons to switch to other views
  Widget _buildViewSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              // Already on Day -> do nothing or show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Already on Day view!")),
              );
            },
            child: const Text('Day'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/week');
            },
            child: const Text('Week'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/month');
            },
            child: const Text('Month'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/year');
            },
            child: const Text('Year'),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLayout() {
    final d = dayData;
    if (d == null) {
      // No data for this date -> show a placeholder
      return Center(child: Text("No schedule data for this day."));
    }

    // If you want an hour-by-hour layout (like WeeklyCalendarScreen):
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int hour = startHour; hour <= endHour; hour++)
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: _buildEventsForHour(d, hour),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsForHour(DayModel dayData, int hour) {
    // Filter events that overlap this hour
    final matchingEvents = dayData.events.where((event) {
      final start = _parseHour(event.startTime);
      final end = _parseHour(event.endTime);
      return (hour >= start && hour < end);
    }).toList();

    if (matchingEvents.isEmpty) {
      return Row(
        children: [
          SizedBox(width: 50, child: Text("$hour:00")),
          const Text(""),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 50, child: Text("$hour:00")),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var ev in matchingEvents)
                Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _parseColor(ev.color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("${ev.name}"),
                ),
            ],
          ),
        ),
      ],
    );
  }

  int _parseHour(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      return int.tryParse(parts[0]) ?? 0;
    }
    return 0;
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue.shade200;
      case 'red':
        return Colors.red.shade200;
      case 'green':
        return Colors.green.shade200;
      case 'orange':
        return Colors.orange.shade200;
      case 'yellow':
        return Colors.yellow.shade200;
      case 'purple':
        return Colors.purple.shade200;
      default:
        return Colors.grey.shade300;
    }
  }
}