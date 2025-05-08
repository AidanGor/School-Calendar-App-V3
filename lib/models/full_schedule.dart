import 'package:school_calendar_app_v3/models/day_model.dart';
import 'package:school_calendar_app_v3/models/off_days.dart';
import 'package:school_calendar_app_v3/models/rotational_schedule.dart';

class FullSchedule {
  final List<List<DayModel>> fullSchedule = [];

  FullSchedule() {
    // Build from Aug 1 2025 to June 30 2026
    final startDate = DateTime(2025, 8, 1);
    final endDate = DateTime(2026, 6, 30);

    // Move startDate back to the previous Sunday if not already Sunday
    DateTime calendarStart = startDate;
    while (calendarStart.weekday != DateTime.sunday) {
      calendarStart = calendarStart.subtract(const Duration(days: 1));
    }

    // Build weeks until we pass endDate
    DateTime current = calendarStart;
    while (!current.isAfter(endDate)) {
      // Create a single week with 7 days
      List<DayModel> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(DayModel(date: current));
        current = current.add(const Duration(days: 1));
      }
      fullSchedule.add(week);
    }
  }

  List<List<DayModel>> returnSchedule() {
    return fullSchedule;
  }

  void assignRotationalDays(RotationalSchedule rotationalSchedule) {
    int rotationalIndex = 0;
    final schoolStart = DateTime(2025, 9, 4);
    final schoolEnd   = DateTime(2026, 6, 10);

    for (var week in fullSchedule) {
      for (var day in week) {
        final date = day.date;
        if ( // date in [schoolStart, schoolEnd]
             !date.isBefore(schoolStart) &&
             !date.isAfter(schoolEnd) &&
             !OffDays.isOffDay(date) &&
             date.weekday != DateTime.saturday &&
             date.weekday != DateTime.sunday
           ) {
          // Assign rotational day
          day.setRotationalDay(
            rotationalSchedule.getDay(rotationalIndex)
          );
          rotationalIndex = (rotationalIndex + 1) % rotationalSchedule.rotationalDays.length;
        }
      }
    }
  }
}