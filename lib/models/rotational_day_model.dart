// rotational_day_model.dart
import 'package:school_calendar_app_v3/models/event_model.dart';

class RotationalDayModel {
  final int dayNumber;
  final List<EventModel> events;

  RotationalDayModel({
    required this.dayNumber,
    List<EventModel>? events,
  }) : events = events ?? [];

  /// Returns events that match a given date string
  List<EventModel> getEventsForDay(String date) {
    return events.where((e) => e.date == date).toList();
  }

  @override
  String toString() {
    return 'Day $dayNumber';
  }
}