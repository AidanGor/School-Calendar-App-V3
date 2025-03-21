// rotational_schedule.dart
import 'package:school_calendar_app_v3/models/rotational_day_model.dart';

class RotationalSchedule {
  final List<RotationalDayModel> rotationalDays;

  RotationalSchedule()
      : rotationalDays = List.generate(7, (i) => RotationalDayModel(dayNumber: i + 1));

  RotationalDayModel getDay(int index) {
    return rotationalDays[index];
  }
}