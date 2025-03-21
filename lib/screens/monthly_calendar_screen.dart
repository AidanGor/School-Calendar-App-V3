import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models (adjust imports to your actual file structure):
import '../models/full_schedule.dart';
import '../models/day_model.dart';
import '../models/event_model.dart';
import '../models/off_days.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  final FullSchedule fullSchedule;
  
  // Remove displayedMonth from the constructor if you want it to start on the current month
  // final DateTime displayedMonth;

  // If you only want to show months from August 2025 to June 2026,
  // you can pass them in or hardcode them here.

  const MonthlyCalendarScreen({
    super.key,
    required this.fullSchedule,
    // required this.displayedMonth,
  });

  @override
  State<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  // 1) Track the displayedMonth in State. We'll start at the current month by default.
  late DateTime displayedMonth;

  // 2) (Optional) If you want to limit to Aug 2025 - June 2026, define boundaries:
  final startDate = DateTime.utc(2025, 8, 1);
  final endDate = DateTime.utc(2026, 6, 30);

  DayModel? _findDayData(DateTime date) {
    for (var week in widget.fullSchedule.returnSchedule()) {
      for (var d in week) {
        if (d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day) {
          return d;
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Force the displayedMonth to a UTC date (for example, September 2025)
    displayedMonth = DateTime.utc(2025, 9);
  }

  // monthly_calendar_screen.dart (within _MonthlyCalendarScreenState)
  Widget _buildViewSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/day');
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
              // Already on Month -> maybe do nothing or show a snackBar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Already on Month!")),
              );
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

  @override
  Widget build(BuildContext context) {
    // 3) Compute the first & last days of displayedMonth
    // Force the first/last day of month in UTC:
    final firstDayOfMonth = DateTime.utc(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime.utc(displayedMonth.year, displayedMonth.month + 1, 0);

    // Find the Sunday on/before firstDayOfMonth:
    DateTime startDate = firstDayOfMonth;
    while (startDate.weekday != DateTime.sunday) {
      // Subtract a day, then recreate as UTC:
      startDate = startDate.subtract(const Duration(days: 1));
      startDate = DateTime.utc(startDate.year, startDate.month, startDate.day);
    }

    // Find the Saturday on/after lastDayOfMonth:
    DateTime endDate = lastDayOfMonth;
    while (endDate.weekday != DateTime.saturday) {
      endDate = endDate.add(const Duration(days: 1));
      endDate = DateTime.utc(endDate.year, endDate.month, endDate.day);
    }

    // Build the list of days from startDate to endDate:
    final days = <DateTime>[];
    DateTime current = startDate;
    while (!current.isAfter(endDate)) {
      days.add(current);
      // Move forward a day, forcing UTC at midnight
      final next = current.add(const Duration(days: 1));
      current = DateTime.utc(next.year, next.month, next.day);
    }

    return Scaffold(
      appBar: AppBar(
        // 4) Show the month name, plus arrow buttons for navigation
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        title: Text(DateFormat('MMMM yyyy').format(displayedMonth)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showCreateEventDialog(context),
      ),
      body: Column(
        children: [
          _buildViewSelector(context),
          // Day-of-week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                .map((name) => Expanded(child: Center(child: Text(name))))
                .toList(),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // We have 'days.length' total days to display, each row has 7 columns
                final totalDays = days.length;
                // Number of rows = totalDays / 7, rounded up
                final rows = (totalDays / 7).ceil();

                // Each cell's width = total width / 7
                final itemWidth = constraints.maxWidth / 7;
                // Each cell's height = total height / number of rows
                final itemHeight = constraints.maxHeight / rows;

                // childAspectRatio = width / height
                final ratio = itemWidth / itemHeight;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalDays,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: ratio,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isCurrentMonth = (day.month == displayedMonth.month);
                    final dayData = _findDayData(day);
                    final isOffDay = OffDays.isOffDay(day);

                    // Decide the background color
                    Color backgroundColor;
                    bool isWeekend = (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday);
                    if (!isCurrentMonth) {
                      backgroundColor = Colors.grey.shade200; // Not this month
                    } else if (isWeekend) {
                      backgroundColor = Colors.orange.shade50;  
                    } else if (isOffDay) {
                      backgroundColor = Colors.red.shade50;  // Off day
                    } else if (dayData?.rotationalDay != null) {
                      backgroundColor = Colors.blue.shade50; // Rotational day
                    } else {
                      backgroundColor = Colors.white;         // Normal school day
                    }

                    // Gather event widgets
                    final eventWidgets = <Widget>[];
                    if (dayData != null && dayData.events.isNotEmpty) {
                      for (var ev in dayData.events) {
                        eventWidgets.add(Text(
                          '• ${ev.name}',
                          style: const TextStyle(fontSize: 10),
                        ));
                      }
                    }

                    // Show rotational day if present
                    final rotationText = (dayData?.rotationalDay != null)
                        ? ' (Rot: ${dayData!.rotationalDay!.dayNumber})'
                        : '';

                    return InkWell(
                      onTap: () => _onDayTap(context, day),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          color: backgroundColor, // <-- updated
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentMonth ? Colors.black : Colors.grey,
                                  ),
                                ),
                                if (rotationText.isNotEmpty)
                                  Text(
                                    rotationText,
                                    style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                                  ),
                              ],
                            ),
                            if (isWeekend) 
                              const Text(
                                'Weekend',
                                style: TextStyle(color: Colors.orange, fontSize: 10),
                              ),
                            
                            if (isOffDay)
                              const Text(
                                'Off Day',
                                style: TextStyle(color: Colors.red, fontSize: 10),
                              ),
                            ...eventWidgets,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to previous month
  void _previousMonth() {
    final year = displayedMonth.year;
    final month = displayedMonth.month == 1 ? 12 : displayedMonth.month - 1;
    final newYear = (displayedMonth.month == 1) ? (year - 1) : year;
    final newMonth = DateTime(newYear, month, 1);

    // If you want to clamp to [minDate, maxDate], do:
    // if (newMonth.isBefore(minDate)) return;
    // Otherwise, remove the check for continuous navigation
    setState(() {
      displayedMonth = newMonth;
    });
  }

  /// Navigate to next month
  void _nextMonth() {
    final year = displayedMonth.year;
    final month = displayedMonth.month == 12 ? 1 : displayedMonth.month + 1;
    final newYear = (displayedMonth.month == 12) ? (year + 1) : year;
    final newMonth = DateTime(newYear, month, 1);

    // If you want to clamp to [minDate, maxDate], do:
    // if (newMonth.isAfter(maxDate)) return;
    // Otherwise, remove the check for continuous navigation
    setState(() {
      displayedMonth = newMonth;
    });
  }

  /// Show a dialog to create an event (no specific day selected).
  void _showCreateEventDialog(BuildContext context) {
    // Controllers for text fields
    final nameController = TextEditingController();
    final eventTypeController = TextEditingController();
    final startTimeController = TextEditingController(text: '09:00');
    final endTimeController = TextEditingController(text: '10:00');
    final colorController = TextEditingController(text: 'Orange');

    // For date picking
    DateTime selectedDate = DateTime.now();

    // For recurrence type
    RecurrenceType selectedRecurrence = RecurrenceType.NONE;

    // If ROTATIONAL is selected, user can specify which rotational day (1–7).
    int rotationalDay = 1;

    // If WEEKDAY is selected, user can specify which weekday (Mon=1 ... Sun=7 in Dart).
    int selectedWeekday = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            // Helper to update state inside the dialog
            void updateDialogState(void Function() fn) {
              setDialogState(fn);
              setState(() {}); // also rebuild parent if needed
            }

            return AlertDialog(
              title: const Text('Create Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NAME
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Event Name'),
                    ),
                    const SizedBox(height: 8),
                    // DATE PICKER
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              updateDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // EVENT TYPE
                    TextField(
                      controller: eventTypeController,
                      decoration: const InputDecoration(labelText: 'Event Type'),
                    ),
                    const SizedBox(height: 8),
                    // RECURRENCE TYPE DROPDOWN
                    Row(
                      children: [
                        const Text('Recurrence:'),
                        const SizedBox(width: 10),
                        DropdownButton<RecurrenceType>(
                          value: selectedRecurrence,
                          items: RecurrenceType.values.map((rt) {
                            return DropdownMenuItem(
                              value: rt,
                              child: Text(rt.name), // .name is from Dart 2.15+ or use rt.toString()
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              updateDialogState(() {
                                selectedRecurrence = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // IF ROTATIONAL: ask user for dayNumber
                    if (selectedRecurrence == RecurrenceType.ROTATIONAL)
                      Row(
                        children: [
                          const Text('Rotational Day:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '1-7'),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 1 && parsed <= 7) {
                                  rotationalDay = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    // IF WEEKDAY: ask user for dayOfWeek
                    if (selectedRecurrence == RecurrenceType.WEEKDAY)
                      Row(
                        children: [
                          const Text('Weekday (Mon=1..Sun=7):'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '1-7'),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 1 && parsed <= 7) {
                                  selectedWeekday = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // START TIME
                    TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
                    ),
                    const SizedBox(height: 8),
                    // END TIME
                    TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
                    ),
                    const SizedBox(height: 8),
                    // COLOR
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    final eventName = nameController.text.trim();
                    if (eventName.isNotEmpty) {
                      final newEvent = EventModel(
                        name: eventName,
                        date: DateFormat('yyyy-MM-dd').format(selectedDate),
                        eventType: eventTypeController.text.trim(),
                        recurrenceType: selectedRecurrence,
                        startTime: startTimeController.text.trim(),
                        endTime: endTimeController.text.trim(),
                        color: colorController.text.trim(),
                        // For rotational or weekday:
                        rotationalDay: (selectedRecurrence == RecurrenceType.ROTATIONAL)
                            ? rotationalDay
                            : null,
                        weekDay: (selectedRecurrence == RecurrenceType.WEEKDAY)
                            ? selectedWeekday
                            : null,
                      );
                      _addEventToSchedule(newEvent);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Tapping a day cell => show existing events & "Add Event"
  void _onDayTap(BuildContext context, DateTime day) {
    final dayData = _findDayData(day);
    if (dayData == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Events on ${DateFormat('yyyy-MM-dd').format(day)}'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dayData.events.isEmpty)
                  const Text('No events.'),
                for (var ev in dayData.events)
                  ListTile(
                    title: Text(ev.name),
                    subtitle: Text(ev.getTime()),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCreateEventForDay(context, day);
              },
              child: const Text('Add Event'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Dialog for adding an event to a specific day
  void _showCreateEventForDay(BuildContext context, DateTime day) {
    // Controllers
    final nameController = TextEditingController();
    final eventTypeController = TextEditingController();
    final startTimeController = TextEditingController(text: '09:00');
    final endTimeController = TextEditingController(text: '10:00');
    final colorController = TextEditingController(text: 'Orange');

    // This dialog fixes the date to the chosen day
    final DateTime selectedDate = day;

    // Recurrence type
    RecurrenceType selectedRecurrence = RecurrenceType.NONE;
    int rotationalDay = 1;
    int selectedWeekday = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void updateDialogState(void Function() fn) {
              setDialogState(fn);
              setState(() {});
            }

            return AlertDialog(
              title: Text('Create Event for ${DateFormat('yyyy-MM-dd').format(day)}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Event Name'),
                    ),
                    const SizedBox(height: 8),
                    // EVENT TYPE
                    TextField(
                      controller: eventTypeController,
                      decoration: const InputDecoration(labelText: 'Event Type'),
                    ),
                    const SizedBox(height: 8),
                    // RECURRENCE TYPE
                    Row(
                      children: [
                        const Text('Recurrence:'),
                        const SizedBox(width: 10),
                        DropdownButton<RecurrenceType>(
                          value: selectedRecurrence,
                          items: RecurrenceType.values.map((rt) {
                            return DropdownMenuItem(
                              value: rt,
                              child: Text(rt.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              updateDialogState(() {
                                selectedRecurrence = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedRecurrence == RecurrenceType.ROTATIONAL)
                      Row(
                        children: [
                          const Text('Rotational Day:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '1-7'),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 1 && parsed <= 7) {
                                  rotationalDay = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    if (selectedRecurrence == RecurrenceType.WEEKDAY)
                      Row(
                        children: [
                          const Text('Weekday (1=Mon..7=Sun):'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '1-7'),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 1 && parsed <= 7) {
                                  selectedWeekday = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final eventName = nameController.text.trim();
                    if (eventName.isNotEmpty) {
                      final newEvent = EventModel(
                        name: eventName,
                        date: DateFormat('yyyy-MM-dd').format(selectedDate),
                        eventType: eventTypeController.text.trim(),
                        recurrenceType: selectedRecurrence,
                        startTime: startTimeController.text.trim(),
                        endTime: endTimeController.text.trim(),
                        color: colorController.text.trim(),
                        rotationalDay: (selectedRecurrence == RecurrenceType.ROTATIONAL)
                            ? rotationalDay
                            : null,
                        weekDay: (selectedRecurrence == RecurrenceType.WEEKDAY)
                            ? selectedWeekday
                            : null,
                      );
                      _addEventToSchedule(newEvent);
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Adds a newly created event and rebuilds
  void _addEventToSchedule(EventModel event) {
    // We'll parse the date in case we need it for NONE recurrence.
    final parsedDate = DateFormat('yyyy-MM-dd').parse(event.date);

    // Get the schedule data once (for convenience).
    final schedule = widget.fullSchedule.returnSchedule();

    setState(() {
      switch (event.recurrenceType) {
        case RecurrenceType.NONE:
          // Only add to the single date chosen
          final dayData = _findDayData(parsedDate);
          if (dayData != null) {
            dayData.events.add(event);
          }
          break;

        case RecurrenceType.ROTATIONAL:
          // Add to EVERY day that has the matching rotational day number
          // e.g. if event.rotationalDay == 3, add to all DayModels with day.rotationalDay.dayNumber == 3
          if (event.rotationalDay == null) return; // sanity check

          for (var week in schedule) {
            for (var dayModel in week) {
              if (dayModel.rotationalDay != null &&
                  dayModel.rotationalDay!.dayNumber == event.rotationalDay) {
                dayModel.events.add(event);
              }
            }
          }
          break;

        case RecurrenceType.WEEKDAY:
          // Add to EVERY day that has the same weekday (Mon=1..Sun=7)
          // e.g. if event.weekDay == 2, add to all DayModels whose date.weekday == 2
          if (event.weekDay == null) return; // sanity check

          for (var week in schedule) {
            for (var dayModel in week) {
              if (dayModel.date.weekday == event.weekDay) {
                dayModel.events.add(event);
              }
            }
          }
          break;
      }
    });
  }
}