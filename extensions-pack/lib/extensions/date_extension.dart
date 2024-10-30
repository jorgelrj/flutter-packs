import 'package:extensions_pack/extensions_pack.dart';
import 'package:intl/intl.dart';

extension DateExtension on Date {
  String formatBy(DateFormat dateFormat) {
    return dateFormat.format(toDateTime(local: true));
  }

  String formated() {
    final now = Date.today();
    final difference = this.difference(now);

    return switch (difference) {
      Duration(inDays: 0) => 'Today',
      Duration(inDays: 1) => 'Tomorrow',
      Duration(inDays: -1) => 'Yesterday',
      _ => switch (this) {
          final date when date.year != now.year => date.formatBy(DateFormat.yMMMd()),
          final date when date.day == 1 => '1st ${date.formatBy(DateFormat.MMM())}',
          final date when date.day == 2 => '2nd ${date.formatBy(DateFormat.MMM())}',
          final date when date.day == 3 => '3rd ${date.formatBy(DateFormat.MMM())}',
          _ => '${day}th ${formatBy(DateFormat.MMM())}',
        },
    };
  }

  bool get isToday {
    final now = Date.today();

    return now == this;
  }

  Date get sundayBefore {
    Date sunday = this;

    while (sunday.weekday != DateTime.sunday) {
      sunday = sunday.addDays(-1);
    }

    return sunday;
  }

  DateRange buildWeekRange({int startWeekday = DateTime.monday}) {
    Date start = this;

    while (start.weekday != startWeekday) {
      start = start.addDays(-1);
    }

    final end = start.addDays(6);

    return DateRange(start: start, end: end);
  }

  bool isBetween(DateRange range) {
    return this >= range.start && this <= range.end;
  }

  bool isSameDayAs(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }
}

extension DateRangeExtension on DateRange {
  Date get middle {
    final days = duration.inDays;
    final middle = start.addDays(days ~/ 2);

    return middle;
  }

  bool isWithin(DateRange range) {
    return start.isAfter(range.start) && end.isBefore(range.end);
  }

  List<Date> get days {
    final days = <Date>[];
    for (var i = start; i <= end; i = i.addDays(1)) {
      days.add(i);
    }

    return days;
  }

  String formatBy(DateFormat dateFormat) {
    return [
      start.formatBy(dateFormat),
      end.formatBy(dateFormat),
    ].join(' - ');
  }
}
