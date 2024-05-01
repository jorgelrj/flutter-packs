import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';

class MonthAndYear extends Equatable {
  final int month;
  final int year;

  const MonthAndYear({
    required this.month,
    required this.year,
  });

  factory MonthAndYear.fromDateTime(DateTime dateTime) {
    return MonthAndYear(
      month: dateTime.month,
      year: dateTime.year,
    );
  }

  @override
  List<Object?> get props => [
        month,
        year,
      ];

  DateTime get monthStart => DateTime.utc(year, month);

  DateTime get monthEnd {
    return DateTime.utc(
      year,
      month,
      monthStart.daysInMonth,
      23,
      59,
      59,
      999,
    );
  }

  DateTimeRange get monthRange {
    return DateTimeRange(
      start: monthStart,
      end: monthEnd,
    );
  }

  DateTimeRange get visibleCalendarRange {
    final start = monthStart.subtract(
      Duration(days: monthStart.weekday - 1),
    );

    final end = monthEnd.add(
      Duration(days: 7 - monthEnd.weekday),
    );

    return DateTimeRange(
      start: DateTime.utc(start.year, start.month, start.day),
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

  bool get isCurrentMonthAndYear {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  bool isBefore(MonthAndYear other) {
    return year < other.year || (year == other.year && month < other.month);
  }

  bool isAfter(MonthAndYear other) {
    return year > other.year || (year == other.year && month > other.month);
  }

  MonthAndYear copyWith({
    int? month,
    int? year,
  }) {
    return MonthAndYear(
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
