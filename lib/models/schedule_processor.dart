import 'package:intl/intl.dart';
import 'package:school_calendar_app_v3/models/event_model.dart';
import 'package:school_calendar_app_v3/models/full_schedule.dart';

class ScheduleProcessor {
  final FullSchedule fullSchedule;
  final List<EventModel> events;

  ScheduleProcessor({
    required this.fullSchedule,
    required this.events,
  });

  /// Assigns events to days in the schedule based on recurrence type.
  void assignEventsToSchedule() {
  
    final formatter = DateFormat('yyyy-MM-dd');

    for (var week in fullSchedule.returnSchedule()) {
      for (var day in week) {
        final currentDate = DateTime(day.date.year, day.date.month, day.date.day);

        for (var event in events) {
          switch (event.recurrenceType) {
            case RecurrenceType.NONE:
              // Non-recurring: match exact date
              final eventDate = formatter.parse(event.date);
              if (_sameDay(currentDate, eventDate)) {
                day.events.add(event);
              }
              break;
            case RecurrenceType.ROTATIONAL:
              // Rotational: check day’s rotational day
              if (day.rotationalDay != null &&
                  day.rotationalDay!.dayNumber == (event.rotationalDay ?? -1)) {
                day.events.add(event);
              }
              break;
            case RecurrenceType.WEEKDAY:
              // Weekly: compare dayOfWeek
              if (currentDate.weekday == (event.weekDay ?? -1)) {
                day.events.add(event);
              }
              break;
          }
        }
      }
    }
  }

  bool _sameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}