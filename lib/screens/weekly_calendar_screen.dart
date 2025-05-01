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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      floatingActionButton: _buildAddEventFAB(),
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
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('E MMM d').format(day),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _findDayData(day)?.rotationalDay != null
                                      ? 'Day ${_findDayData(day)!.rotationalDay!.dayNumber}'
                                      : '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
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

  /// Reusable FAB for adding events
  Widget _buildAddEventFAB() {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: _showCreateEventDialog,
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
      child: GestureDetector(
        onLongPress: () {
          _confirmDeleteEvent(event);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _parseColor(event.color),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${event.name} (${_formatHourFromString(event.startTime)} - ${_formatHourFromString(event.endTime)})',
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
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

  String _formatHourFromString(String timeStr) {
    // Assumes the input is already like "9:00 AM" or "2:30 PM"
    return timeStr.trim();
  }
  
  void _confirmDeleteEvent(EventModel event) {
    if (event.recurrenceType == RecurrenceType.NONE) {
      // Default single delete popup
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete Event"),
          content: Text("Are you sure you want to delete '${event.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteEvent(event);
                Navigator.pop(ctx);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      // Offer delete options for recurring events
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete Recurring Event"),
          content: Text("Do you want to delete just this instance of '${event.name}', all instances, or all future instances?"),
          actions: [
            TextButton(
              onPressed: () {
                _deleteSingleInstance(event);
                Navigator.pop(ctx);
              },
              child: const Text("Just this one"),
            ),
            TextButton(
              onPressed: () {
                _deleteAllMatchingEvents(event);
                Navigator.pop(ctx);
              },
              child: const Text("All instances"),
            ),
            TextButton(
              onPressed: () {
                _deleteFutureMatchingEvents(event);
                Navigator.pop(ctx);
              },
              child: const Text("All future"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
    }
  }
  
  void _deleteEvent(EventModel event) {
    setState(() {
      for (var week in widget.fullSchedule.returnSchedule()) {
        for (var day in week) {
          day.events.removeWhere((e) =>
            e.name == event.name &&
            e.startTime == event.startTime &&
            e.endTime == event.endTime &&
            e.date == event.date && // Ensures it's this instance only
            e.eventType == event.eventType &&
            e.recurrenceType == event.recurrenceType);
        }
      }
    });
  }

  void _deleteAllMatchingEvents(EventModel event) {
    setState(() {
      for (var week in widget.fullSchedule.returnSchedule()) {
        for (var day in week) {
          day.events.removeWhere((e) =>
            e.name == event.name &&
            e.startTime == event.startTime &&
            e.endTime == event.endTime &&
            e.eventType == event.eventType &&
            e.recurrenceType == event.recurrenceType
          );
        }
      }
    });
  }

  void _deleteFutureMatchingEvents(EventModel event) {
    final thisDate = DateTime.parse(event.date);
    setState(() {
      for (var week in widget.fullSchedule.returnSchedule()) {
        for (var day in week) {
          final dayDate = day.date;
          if (!dayDate.isBefore(thisDate)) {
            day.events.removeWhere((e) =>
              e.name == event.name &&
              e.startTime == event.startTime &&
              e.endTime == event.endTime &&
              e.eventType == event.eventType &&
              e.recurrenceType == event.recurrenceType
            );
          }
        }
      }
    });
  }

  void _deleteSingleInstance(EventModel event) {
    final targetDate = DateTime.parse(event.date);
    setState(() {
      for (var week in widget.fullSchedule.returnSchedule()) {
        for (var day in week) {
          final d = day.date;
          if (d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day) {
            day.events.removeWhere((e) =>
              e.name == event.name &&
              e.date == event.date &&
              e.startTime == event.startTime &&
              e.endTime == event.endTime &&
              e.recurrenceType == event.recurrenceType
            );
          }
        }
      }
    });
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
    final startTimeController = TextEditingController(text: "9:00 AM");
    final endTimeController = TextEditingController(text: "10:00 AM");
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
                    DropdownButtonFormField<String>(
                      value: startTimeController.text,
                      items: _get12HourTimes().map((time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            startTimeController.text = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Start Time'),
                    ),
                    const SizedBox(height: 8),

                    // End Time
                    DropdownButtonFormField<String>(
                      value: endTimeController.text,
                      items: _get12HourTimes().map((time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            endTimeController.text = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'End Time'),
                    ),
                    const SizedBox(height: 8),

                    // Color (Dropdown)
                    DropdownButtonFormField<String>(
                      value: colorController.text,
                      items: ['Blue', 'Red', 'Green', 'Orange', 'Yellow', 'Purple'].map((color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            colorController.text = value;
                          });
                        }
                      },
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

  List<String> _get12HourTimes() {
    final times = <String>[];
    for (int h = 0; h < 24; h++) {
      final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final suffix = h < 12 ? 'AM' : 'PM';
      times.add('$hour:00 $suffix');
      times.add('$hour:30 $suffix');
    }
    return times;
  }