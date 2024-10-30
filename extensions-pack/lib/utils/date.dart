import 'package:flutter/material.dart';

/// A calendar date in the proleptic Gregorian calendar.
///
/// Uses an UTC [DateTime] for all calculations, so has the same behavior and
/// limits as that.
// Comment out the following line until extension types are released.
// extension type Date._(DateTime _time) { /*
class Date {
  final DateTime _time;

  //*/
  /// Calendar date of the [year], [month] and [day].
  ///
  /// The [month] and [day] are normalized to be in the range 1 through 12
  /// for months, and 1 through length-of-month for the day.
  /// Overflow or underflow is moved into the next larger unit, month
  /// or year.
  ///
  /// The normalized date must be in the range
  /// -271821-04-20 through 275760-09-13 (100_000_000 days to either side of
  /// the Dart `DateTime` epoch of 1970-01-01).
  Date(int year, [int month = 1, int day = 1]) : this._(DateTime.utc(year, month, day));

  Date._(this._time);

  @override
  String toString() => _time.toString();

  /// The calendar date of the [dateAndTime].
  Date.from(DateTime dateAndTime) : this(dateAndTime.year, dateAndTime.month, dateAndTime.day);

  /// Date of the [julianDay]th Julian Day.
  Date.fromJulianDay(int julianDay) : this._fromDaysSinceEpoch(julianDay - _julianDayOfEpoch);

  /// Date of [days] since 0000-01-01.
  Date.fromDaysSinceZero(int days) : this._fromDaysSinceEpoch(days - _zeroDayOfEpoch);

  /// Date of [days] since the arbitrary calendar epoch 1970-01-01.
  Date._fromDaysSinceEpoch(int days)
      : this._(
          DateTime.fromMillisecondsSinceEpoch(
            days * Duration.millisecondsPerDay,
            isUtc: true,
          ),
        );

  /// Today's date.
  Date.today() : this.from(DateTime.timestamp());

  /// Parses a formatted date.
  ///
  /// Accepts the same formats as [DateTime.parse],
  /// and throws away the time.
  /// Throws a [FormatException] if the input is not accepted.
  factory Date.parse(String formattedDate) => Date.from(DateTime.parse(formattedDate));

  /// Tries to parse a formatted date.
  ///
  /// Accepts the same formats as [DateTime.parse],
  /// and throws away the time.
  /// Returns `null` if the input is not accepted.
  static Date? tryParse(String formattedDate) {
    final time = DateTime.tryParse(formattedDate);
    if (time == null) return null;
    return Date.from(time);
  }

  /// Calendar year.
  int get year => _time.year;

  /// Calendar month.
  ///
  /// Always in the range 1 through 12, representing January through December.
  int get month => _time.month;

  /// Day in month.
  ///
  /// Always a number in the range 1 through 31 for long months, 30 for shorter months,
  /// and 28 or 20 for February, depending on whether it's a leap year.
  int get day => _time.day;

  /// The number of days in the current month.
  int get daysInMonth {
    return const [31, null, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1] ?? (isLeapYear ? 29 : 28);
  }

  /// Day in year.
  ///
  /// The number of days in the year up to and including the current day.
  /// The day-in-year of the 1st of January is 1.
  ///
  /// A date `date` can be recreated by `Date(date.year, 1, date.dayInYear)`.
  int get dayInYear {
    final startOfYear = DateTime.utc(year);
    return 1 + (_time.millisecondsSinceEpoch - startOfYear.millisecondsSinceEpoch) ~/ Duration.millisecondsPerDay;
  }

  /// Whether this year is a leap-year.
  ///
  /// A year in the proleptic Gregorian calendar is a leap year if:
  /// * It's divisible by 4, and
  /// * It's not divisible by 100, unless
  /// * It's also divisble by 400.
  ///
  /// This gives 97 leap years per 400 years.
  bool get isLeapYear {
    final year = this.year;
    return (year & 0x3 == 0) && ((year & 0xC != 0) || (year % 25 == 0));
  }

  /// Julian day of the day.
  ///
  /// This is the number of days since the epoch of the Julian calendar,
  /// which is -4713-11-24 in the proleptic Gregorian calendar.
  int get julianDay => _daysSinceEpoch - _julianDayOfEpoch;

  int get weekday => _time.weekday;

  /// Whether this date is strictly before [other].
  bool operator <(Date other) => _daysSinceEpoch < other._daysSinceEpoch;

  /// Whether this date is no later than [other].
  bool operator <=(Date other) => _daysSinceEpoch <= other._daysSinceEpoch;

  /// Whether this date is strictly after [other].
  bool operator >(Date other) => _daysSinceEpoch > other._daysSinceEpoch;

  /// Whether this date is no earlier than [other].
  bool operator >=(Date other) => _daysSinceEpoch >= other._daysSinceEpoch;

  /// Whether this date is the same as [other].
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is Date && other._daysSinceEpoch == _daysSinceEpoch;
  }

  @override
  int get hashCode => _daysSinceEpoch;

  /// The number of whole days from this date to [other].
  ///
  /// Is negative if [other] is before this date.
  int dayDifference(Date other) => other._daysSinceEpoch - _daysSinceEpoch;

  /// A calendar date [days] later than this one, or earlier if [days] is negative.
  Date addDays(int days) => Date._fromDaysSinceEpoch(_daysSinceEpoch + days);

  /// Modifies the year, month and day by adding to their values.
  ///
  /// The [years], [months] and [days] are added to
  /// the [year], [month] and [day] of the current date,
  /// then normalized to a valid calendar date.
  /// The added values can be negative.
  ///
  /// Doing `date.add(years: y, months: m, days: d)` is qquivalent
  /// to `Date(date.year + y, date.month + m, date.day + d)`.
  Date add({int years = 0, int months = 0, int days = 0}) => Date(year + years, month + months, day + days);

  /// Updates the individual year, month or day to a new value.
  ///
  /// If the result is not a valid calendar date, either
  /// by directly setting an invalid value, like a month of 14,
  /// or by chaning the year and month so that the day is now
  /// greater than the length of the month, the date is
  /// normalized the same way as the [Date] constructor.
  Date update({int? year, int? month, int? day}) => Date(year ?? this.year, month ?? this.month, day ?? this.day);

  /// Entire calendar days since 1970-01-01.
  ///
  /// Complicated by extension types not being able to prevent
  /// any `DateTime` from being cast to `Date`.
  /// For `Date`s created using the extension type constructors,
  /// the `isUtc` is always true and the milliseconds are always
  /// a multiple of [Duration.millisecondsPerDay].
  int get _daysSinceEpoch {
    var ms = _time.millisecondsSinceEpoch;
    if (!_time.isUtc) {
      ms += _time.timeZoneOffset.inMilliseconds;
    }
    return ms ~/ Duration.millisecondsPerDay;
  }

  /// Creates a `DateTime` object with the current date, at midnight.
  ///
  /// The default is to create a UTC `DateTime`.
  /// If [local] is true, the created `DateTime` is local time.
  /// Be aware that some locations switch daylight saving time
  /// at midnight.
  DateTime toDateTime({bool local = false}) => local
      ? DateTime(year, month, day)
      : DateTime.fromMillisecondsSinceEpoch(
          _daysSinceEpoch * Duration.millisecondsPerDay,
        );

  /// This date as a simple "year-month-day" string.
  ///
  /// If the year is negative, it starts with a minus sign.
  /// The year is padded to at least four digits,
  /// the month and day to two digits.
  String toDateString() {
    final year = this.year;
    final month = this.month;
    final day = this.day;
    String yearString;
    if (year.abs() < 1000) {
      yearString = year.abs().toString().padLeft(4, '0');
      if (year < 0) yearString = '-$yearString';
    } else {
      yearString = year.toString();
    }
    return "$yearString-${month < 10 ? "0" : ""}$month-${day < 10 ? "0" : ""}$day";
  }

  /// Returns a [Duration] of the time between [this] and [other].
  Duration difference(Date other) => _time.difference(other._time);

  /// Returns if this date is after [other].
  bool isAfter(Date other) => _time.isAfter(other._time);

  /// Returns if this date is before [other].
  bool isBefore(Date other) => _time.isBefore(other._time);

  /// Days between -4713-11-24 and 1970-01-01.
  static const int _julianDayOfEpoch = 2440588;

  /// Days between 0000-01-01 and 1970-01-01
  static const int _zeroDayOfEpoch = 719528;
}

class DateRange {
  /// Creates a date range for the given start and end [DateTime].
  DateRange({
    required this.start,
    required this.end,
  }) : assert(!start.isAfter(end));

  /// The start of the range of dates.
  final Date start;

  /// The end of the range of dates.
  final Date end;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [Date.difference] for more details.
  Duration get duration => end.difference(start);

  DateTimeRange toDateTimeRange() {
    return DateTimeRange(
      start: DateTime.utc(
        start.year,
        start.month,
        start.day,
      ),
      end: DateTime.utc(
        end.year,
        end.month,
        end.day,
        23,
        59,
        59,
        999,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start - $end';
}

extension DateTimeDate on DateTime {
  /// Extracts the calendar date from this `DateTime`.
  Date toDate() => Date.from(this);

  /// Whether this date and time only contains a date.
  ///
  /// A date time is considered to only contain a date
  /// when it's in the UTC time zone, and is precisely
  /// at midnight (hours, minutes, seconds, and milliseconds
  /// are all zero).
  bool get isDate => isUtc && (millisecondsSinceEpoch % Duration.millisecondsPerDay) == 0;
}

extension DateTimeRangeDateRange on DateTimeRange {
  /// Extracts the calendar date range from this `DateTimeRange`.
  DateRange toDateRange() {
    return DateRange(
      start: start.toDate(),
      end: end.toDate(),
    );
  }
}
