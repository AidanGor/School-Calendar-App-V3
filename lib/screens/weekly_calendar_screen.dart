import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/full_schedule.dart';
import '../models/day_model.dart';
import '../models/event_model.dart';

class WeeklyCalendarScreen extends StatefulWidget {
  final FullSchedule fullSchedule;
  final DateTime startOfWeek;

  const WeeklyCalendarScreen({
    Key? key,
    required this.fullSchedule,
    required this.startOfWeek,
  }) : super(key: key);

  @override
  State<WeeklyCalendarScreen> createState() => _WeeklyCalendarScreenState();
}

class _WeeklyCalendarScreenState extends State<WeeklyCalendarScreen> {
  final int startHour = 0;
  final int endHour = 23;

  // We track the currently displayed week here
  late DateTime currentStartOfWeek;

  @override
  void initState() {
    super.initState();
    // Initialize with the startOfWeek passed into the widget
    currentStartOfWeek = widget.startOfWeek;
  }

  @override
  Widget build(BuildContext context) {
    // Build a list of the 7 days in this week (e.g., Sunday..Saturday)
    List<DateTime> weekDays = List.generate(7, (i) {
      return currentStartOfWeek.add(Duration(days: i));
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousWeek,
        ),
        title: Text(
          'Weekly View: ${DateFormat('yyyy-MM-dd').format(currentStartOfWeek)}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showCreateEventDialog,
      ),

      body: Column(
        children: [
          _buildViewSelector(context),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // Row of day headers
                  Row(
                    children: [
                      const SizedBox(width: 60), // blank space for hour labels
                      for (var day in weekDays)
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat('E MMM d').format(day), // e.g. "Sun Sep 4"
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // For each hour, create a row
                  for (int hour = startHour; hour <= endHour; hour++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hour label in 12-hour format
                        SizedBox(
                          width: 60,
                          child: Text(
                            _formatHour(hour),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        // 7 columns for each day
                        for (var day in weekDays)
                          Expanded(
                            child: Container(
                              height: 60, // each hour row is 60px tall
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              // Use a Stack to position event bars
                              child: _buildHourCell(day, hour),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Move back one week
  void _previousWeek() {
    setState(() {
      currentStartOfWeek = currentStartOfWeek.subtract(const Duration(days: 7));
    });
  }

  /// Move forward one week
  void _nextWeek() {
    setState(() {
      currentStartOfWeek = currentStartOfWeek.add(const Duration(days: 7));
    });
  }

  // ---------------------------------------------------------------------------
  //  Build Methods
  // ---------------------------------------------------------------------------

  Widget _buildViewSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/day');
            },
            child: const Text('Day'),
          ),
          const SizedBox(width: 8),
          // Week
          OutlinedButton(
            onPressed: () {
              // Already on Week
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already on Week view!')),
              );
            },
            child: const Text('Week'),
          ),
          const SizedBox(width: 8),
          // Month
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/month');
            },
            child: const Text('Month'),
          ),
          const SizedBox(width: 8),
          // Year
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

  /// Builds the cell for a given [day, hour] as a Stack of event bars
  Widget _buildHourCell(DateTime day, int hour) {
    final dayData = _findDayData(day);
    if (dayData == null) return const SizedBox();

    final matchingEvents = <EventModel>[];
    for (var ev in dayData.events) {
      final (startH, startM) = _parseTime(ev.startTime);
      final (endH, endM) = _parseTime(ev.endTime);

      // Check if [hour, hour+1) intersects [startH:startM, endH:endM).
      if (startH < hour + 1 && endH >= hour) {
        matchingEvents.add(ev);
      }
    }
    if (matchingEvents.isEmpty) return const SizedBox();

    return Stack(
      children: [
        for (var ev in matchingEvents)
          _buildEventBar(ev, hour),
      ],
    );
  }

  /// Builds a single event bar (Positioned) within the hour cell
  Widget _buildEventBar(EventModel event, int hourCell) {
    final (startH, startM) = _parseTime(event.startTime);
    final (endH, endM) = _parseTime(event.endTime);

    // The hour cell covers [hourCell : hourCell+1).
    final cellStartMin = (hourCell == startH) ? startM : 0;
    final cellEndMin = (hourCell == endH) ? endM : 60;

    if (cellEndMin <= cellStartMin) {
      return const SizedBox();
    }

    final topOffset = cellStartMin.toDouble(); 
    final barHeight = (cellEndMin - cellStartMin).toDouble();

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0, 
      height: barHeight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _parseColor(event.color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          event.name,
          style: const TextStyle(fontSize: 10),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  Utility Methods
  // ---------------------------------------------------------------------------

  DayModel? _findDayData(DateTime day) {
    for (var week in widget.fullSchedule.returnSchedule()) {
      for (var d in week) {
        if (d.date.year == day.year &&
            d.date.month == day.month &&
            d.date.day == day.day) {
          return d;
        }
      }
    }
    return null;
  }

  (int hour, int minute) _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return (h, m);
    }
    return (0, 0);
  }

  String _formatHour(int hour24) {
    final suffix = (hour24 < 12) ? 'AM' : 'PM';
    final hour12 = (hour24 == 0)
        ? 12
        : (hour24 > 12 ? hour24 - 12 : hour24);
    return '$hour12 $suffix';
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

  // ---------------------------------------------------------------------------
  //  FAB - Create Event
  // ---------------------------------------------------------------------------
  void _showCreateEventDialog() {
    // We'll implement a basic form with name, date, startTime, endTime, color
    // By default, date is one of the 7 days in the displayed week
    // We'll let the user pick from a dropdown
    final daysInWeek = List.generate(7, (i) {
      return currentStartOfWeek.add(Duration(days: i));
    });

    // Basic controllers
    final nameController = TextEditingController();
    final startTimeController = TextEditingController(text: "09:00");
    final endTimeController = TextEditingController(text: "10:00");
    final colorController = TextEditingController(text: "Blue");

    // We'll store which day the user picked
    DateTime selectedDay = daysInWeek[0]; // default to first day in the week

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text("Create New Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Event Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Event Name'),
                    ),
                    const SizedBox(height: 8),

                    // Day Picker
                    Row(
                      children: [
                        const Text("Date: "),
                        const SizedBox(width: 8),
                        DropdownButton<DateTime>(
                          value: selectedDay,
                          items: daysInWeek.map((day) {
                            return DropdownMenuItem<DateTime>(
                              value: day,
                              child: Text(DateFormat('E MMM d').format(day)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedDay = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Start Time
                    TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
                    ),
                    const SizedBox(height: 8),

                    // End Time
                    TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
                    ),
                    const SizedBox(height: 8),

                    // Color
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final eventName = nameController.text.trim();
                    if (eventName.isNotEmpty) {
                      // Build an EventModel
                      final newEvent = EventModel(
                        name: eventName,
                        // We'll store date as "yyyy-MM-dd"
                        date: DateFormat('yyyy-MM-dd').format(selectedDay),
                        eventType: 'UserCreated',
                        recurrenceType: RecurrenceType.NONE, // for now
                        startTime: startTimeController.text.trim(),
                        endTime: endTimeController.text.trim(),
                        color: colorController.text.trim(),
                      );

                      _addEventToSchedule(selectedDay, newEvent);
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Adds the new event to the correct DayModel and rebuilds
  void _addEventToSchedule(DateTime day, EventModel event) {
    final dayData = _findDayData(day);
    if (dayData != null) {
      setState(() {
        dayData.events.add(event);
      });
    }
  }
}