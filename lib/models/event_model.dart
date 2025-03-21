// event_model.dart
enum RecurrenceType {
  NONE,
  ROTATIONAL,
  WEEKDAY,
}

class EventModel {
  final String name;
  final String date;        // Alternatively, DateTime if you prefer
  final String eventType;
  final RecurrenceType recurrenceType;
  final String startTime;
  final String endTime;
  final String color;
  final int? rotationalDay; // For ROTATIONAL recurrence
  final int? weekDay;       // For WEEKDAY recurrence (Dart uses Monday=1, Sunday=7 if we do dateTime.weekday)

  EventModel({
    required this.name,
    required this.date,
    required this.eventType,
    required this.recurrenceType,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.rotationalDay,
    this.weekDay,
  });

  // For convenience, returns the time range as a single string
  String getTime() {
    return '$startTime - $endTime';
  }

  @override
  String toString() {
    return name;
  }
}