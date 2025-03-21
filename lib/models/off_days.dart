// off_days.dart

/// Manages a set of off-day [DateTime]s.
class OffDays {
  /// A static set of off days.
  static final Set<DateTime> offDays = {};

  // Populates the offDays set, similar to your static block in Java
  static void initializeOffDays() {
    // Single days
    addOffDay(DateTime(2025, 9, 23));
    addOffDay(DateTime(2025, 10, 31));
    addOffDay(DateTime(2025, 11, 21));
    addOffDay(DateTime(2026, 1, 19));
    addOffDay(DateTime(2026, 4, 17));
    addOffDay(DateTime(2026, 5, 25));

    // Ranges (skip weekends)
    addOffDayRange(DateTime(2025, 10, 2), DateTime(2025, 10, 3));
    addOffDayRange(DateTime(2025, 11, 26), DateTime(2025, 12, 1));
    addOffDayRange(DateTime(2025, 12, 22), DateTime(2026, 1, 2));
    addOffDayRange(DateTime(2026, 2, 13), DateTime(2026, 2, 16));
    addOffDayRange(DateTime(2026, 3, 20), DateTime(2026, 4, 3));
  }

  /// Adds a single off day, skipping weekends
  static void addOffDay(DateTime date) {
    if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
      offDays.add(_onlyDate(date));
    }
  }

  /// Adds a range of off days from [start] to [end], skipping weekends
  static void addOffDayRange(DateTime start, DateTime end) {
    var current = start;
    while (!current.isAfter(end)) {
      if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
        offDays.add(_onlyDate(current));
      }
      current = current.add(const Duration(days: 1));
    }
  }

  static bool isOffDay(DateTime date) {
    return offDays.contains(_onlyDate(date));
  }

  /// Ensures we only compare date components (year-month-day) ignoring time
  static DateTime _onlyDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }
}