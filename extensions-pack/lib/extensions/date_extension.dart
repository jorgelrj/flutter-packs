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

  bool isBetween(DateRange range) {
    return this >= range.start && this <= range.end;
  }

  bool isSameDayAs(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }
}
