extension DateEPExtension on DateTime {
  DateTime get beginningOfMonth => DateTime.utc(year, month);

  int get daysInMonth {
    return switch (month) {
      2 => isLeapYear ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      1 || 3 || 5 || 7 || 8 || 10 || 12 => 31,
      _ => 0,
    };
  }

  DateTime get endOfDay {
    return startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  }

  bool get isLastDayOfMonth => day == daysInMonth;

  bool get isLeapYear {
    bool leapYear = false;

    final bool leap = (year % 100 == 0) && (year % 400 != 0);
    if (leap) {
      leapYear = false;
    } else if (year % 4 == 0) {
      leapYear = true;
    }

    return leapYear;
  }

  bool get isToday => isSameDayAs(DateTime.now());

  bool get isTodayOrAfter => isToday || isSameOrAfter(DateTime.now());

  bool get isTodayOrBefore => isToday || isSameOrBefore(DateTime.now());

  bool get isTomorrow => isSameDayAs(DateTime.now().addDays(1));

  bool get isWeekend {
    return weekday == DateTime.sunday || weekday == DateTime.saturday;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get sundayBefore {
    DateTime sunday = this;
    while (sunday.weekday != DateTime.sunday) {
      sunday = sunday.subtractDays(1);
    }
    return sunday.startOfDay;
  }

  DateTime get mondayBefore {
    DateTime monday = this;
    while (monday.weekday != DateTime.monday) {
      monday = monday.subtractDays(1);
    }
    return monday.startOfDay;
  }

  int get weekDayBaseSunday {
    return switch (weekday) {
      DateTime.sunday => 0,
      DateTime.monday => 1,
      DateTime.tuesday => 2,
      DateTime.wednesday => 3,
      DateTime.thursday => 4,
      DateTime.friday => 5,
      _ => 6,
    };
  }

  int get weekOfYear {
    final firstDayOfYear = DateTime(year);
    final days = differenceInDays(firstDayOfYear);

    return (days / 7).ceil();
  }

  DateTime addDays(int days) => add(Duration(days: days));

  /// Returns date as the first day of the next month
  DateTime addMonths(int months) {
    final finalMonth = month + months;

    return DateTime(
      year + (finalMonth > 12 ? finalMonth ~/ 12 : 0),
      finalMonth > 12 ? finalMonth % 12 : finalMonth,
    );
  }

  int differenceInDays(DateTime date) => difference(date).inDays;

  bool isBetween(DateTime start, DateTime finish) {
    return isAfter(start) && isBefore(finish);
  }

  bool isSameDayAs(DateTime date) {
    return day == date.day && month == date.month && year == date.year;
  }

  bool isSameOrAfter(DateTime date) => isAtSameMomentAs(date) || isAfter(date);

  bool isSameOrBefore(DateTime date) => isAtSameMomentAs(date) || isBefore(date);

  DateTime subtractDays(int days) => subtract(Duration(days: days));

  DateTime operator +(Duration duration) => add(duration);

  DateTime operator -(Duration duration) => subtract(duration);

  bool operator >(DateTime date) => isAfter(date);

  bool operator >=(DateTime date) => isSameOrAfter(date);

  bool operator <(DateTime date) => isBefore(date);

  bool operator <=(DateTime date) => isSameOrBefore(date);
}
