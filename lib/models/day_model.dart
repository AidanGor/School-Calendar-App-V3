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

  /// Removes events by name, similar to removeEvent(String eventName) in Java.
  void removeSingleEvent(String name, String date) {
    events.removeWhere((e) => e.name == name && e.date == date);
  }

  void setRotationalDay(RotationalDayModel rd) {
    rotationalDay = rd;
  }
}