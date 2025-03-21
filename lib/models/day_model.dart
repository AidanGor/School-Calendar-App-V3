// day_model.dart
import 'package:school_calendar_app_v3/models/event_model.dart';
import 'package:school_calendar_app_v3/models/rotational_day_model.dart';

class DayModel {
  final DateTime date;
  RotationalDayModel? rotationalDay;
  final List<EventModel> events;

  DayModel({
    required this.date,
    this.rotationalDay,
    List<EventModel>? events,
  }) : events = events ?? [];

  /// Removes events by name, akin to removeEvent(String eventName) in Java.
  void removeEvent(String eventName) {
    events.removeWhere((e) => e.name == eventName);
  }

  void setRotationalDay(RotationalDayModel rd) {
    rotationalDay = rd;
  }
}