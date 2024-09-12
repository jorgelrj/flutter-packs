import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppDaysPicker extends StatefulWidget {
  final AppItemsHandler<DateTime> handler;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final bool Function(DateTime)? selectableDatePredicate;
  final ValueChanged<DateTime>? onDateChanged;
  final String? Function(DateTime)? tooltipBuilder;
  final Widget Function(Widget child, [DateTime? date])? dayBuilder;
  final bool enabled;
  final DateTimeRange? selectedDisplayRange;
  final Function(MonthAndYear date)? onDisplayedMonthChanged;
  final bool showTitle;

  const AppDaysPicker({
    required this.handler,
    required this.firstDate,
    required this.lastDate,
    this.selectableDatePredicate,
    this.dayBuilder,
    this.onDateChanged,
    this.tooltipBuilder,
    this.enabled = true,
    this.selectedDisplayRange,
    this.onDisplayedMonthChanged,
    this.initialDate,
    this.showTitle = true,
    super.key,
  });

  @override
  State<AppDaysPicker> createState() => _AppDaysPickerState();
}

class _AppDaysPickerState extends State<AppDaysPicker> {
  static const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late final ValueNotifier<Iterable<DateTime>> _datesNotifier;
  late final ValueNotifier<MonthAndYear> _monthYearNotifier;

  void _datesListener() {
    widget.handler.onListChanged(_datesNotifier.value.toList());
  }

  void _onChangeDate(DateTime date) {
    if (!widget.enabled) {
      return;
    }

    final selectedDates = _datesNotifier.value;
    final isSelected = selectedDates.any((d) => d.isSameDayAs(date));

    final isSelectable = widget.selectableDatePredicate?.call(date) ?? true;

    if (!isSelectable) {
      return;
    }

    final isBeforeStart = date.isBefore(widget.firstDate);
    final isSameAsStart = date.isSameDayAs(widget.firstDate);

    if (isBeforeStart && !isSameAsStart) {
      return;
    }

    if (isSelected) {
      _datesNotifier.value = switch (widget.handler) {
        (final AppSingleItemHandler<DateTime> _) => [],
        (final AppMultipleItemsHandler<DateTime> _) => selectedDates.where((it) => it != date),
      };
    } else {
      _datesNotifier.value = switch (widget.handler) {
        (final AppSingleItemHandler<DateTime> _) => [date],
        (final AppMultipleItemsHandler<DateTime> _) => [...selectedDates, date],
      };
    }

    widget.onDateChanged?.call(date);
  }

  ({
    Color borderColor,
    Color backgroundColor,
    Color textColor,
    bool isRangeStart,
    bool isRangeEnd,
    bool isBetweenRange,
  }) _dateData(DateTime date) {
    final selectedDisplayRange = widget.selectedDisplayRange;

    final isSelected = selectedDisplayRange == null && _datesNotifier.value.any((d) => d.isSameDayAs(date));
    final isToday = date.isToday;
    final isDisabled = !date.isSameDayAs(widget.firstDate) && date.isBefore(widget.firstDate);
    final isRangeStart = selectedDisplayRange?.start.isSameDayAs(date) ?? false;
    final isRangeEnd = selectedDisplayRange?.end.isSameDayAs(date) ?? false;

    final isBetweenRange = selectedDisplayRange != null &&
        date.isAfter(selectedDisplayRange.start) &&
        date.isBefore(selectedDisplayRange.end);

    return (
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
      isBetweenRange: isBetweenRange,
      borderColor: isToday ? context.colorScheme.primary : Colors.transparent,
      backgroundColor: isSelected || isRangeStart || isRangeEnd ? context.colorScheme.primary : Colors.transparent,
      textColor: isDisabled
          ? context.colorScheme.onSurface.withOpacity(0.5)
          : isSelected || isRangeStart || isRangeEnd
              ? context.colorScheme.onPrimary
              : isToday
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
    );
  }

  @override
  void initState() {
    super.initState();

    _datesNotifier = switch (widget.handler) {
      (final AppSingleItemHandler<DateTime> handler) =>
        ValueNotifier([widget.initialDate ?? handler.initialValue].whereNotNull()),
      (final AppMultipleItemsHandler<DateTime> handler) => ValueNotifier(handler.initialValue),
    };

    _monthYearNotifier = ValueNotifier(
      MonthAndYear.fromDateTime(_datesNotifier.value.firstOrNull ?? DateTime.now()),
    );

    _monthYearNotifier.addListener(() {
      widget.onDisplayedMonthChanged?.call(_monthYearNotifier.value);
    });

    _datesNotifier.addListener(_datesListener);
  }

  @override
  void didUpdateWidget(covariant AppDaysPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialDate != null && MonthAndYear.fromDateTime(widget.initialDate!) != _monthYearNotifier.value) {
      _monthYearNotifier.value = MonthAndYear.fromDateTime(widget.initialDate!);
    }

    if (widget.handler != oldWidget.handler) {
      _datesNotifier.value = switch (widget.handler) {
        (final AppSingleItemHandler<DateTime> handler) => [handler.initialValue].whereNotNull(),
        (final AppMultipleItemsHandler<DateTime> handler) => handler.initialValue,
      };
    }
  }

  @override
  void dispose() {
    _datesNotifier.dispose();
    _monthYearNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showTitle) ...[
                  const LabelLarge('Select date'),
                  const Spacing(mainAxisExtent: 36),
                ],
                ValueListenableBuilder<MonthAndYear>(
                  valueListenable: _monthYearNotifier,
                  builder: (context, selection, child) {
                    return HeadlineLarge(
                      DateFormat('MMM, y').format(selection.toDateTime()),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(color: context.colorScheme.outlineVariant),
          ValueListenableBuilder<MonthAndYear>(
            valueListenable: _monthYearNotifier,
            builder: (context, selection, child) {
              final canGoBack = selection.toDateTime().isAfter(widget.firstDate);
              final canGoForward = selection.toDateTime().isBefore(widget.lastDate);

              return Row(
                children: [
                  const Spacer(),
                  AppButton.icon(
                    onPressed: canGoBack ? () => _monthYearNotifier.value = selection.previousMonth() : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  AppButton.icon(
                    onPressed: canGoForward ? () => _monthYearNotifier.value = selection.nextMonth() : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              );
            },
          ),
          ValueListenableBuilder<MonthAndYear>(
            valueListenable: _monthYearNotifier,
            builder: (context, selection, child) {
              final daysInMonth = selection.toDateTime().daysInMonth;
              final gridCount = 7 + ((daysInMonth / 7).ceil() * 7);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemBuilder: (context, index) {
                  if (index < 7) {
                    return Center(
                      child: BodyLarge(
                        _weekDays[index],
                      ),
                    );
                  }

                  final realIndex = index - 7;
                  final firstWeekDay = selection.toDateTime().weekDayBaseSunday;

                  if (realIndex < firstWeekDay - 1 || realIndex >= daysInMonth + firstWeekDay - 1) {
                    return const SizedBox();
                  }

                  final date = DateTime(
                    selection.year,
                    selection.month,
                    realIndex - firstWeekDay + 2,
                  );

                  return Center(
                    child: ValueListenableBuilder<Iterable<DateTime>>(
                      valueListenable: _datesNotifier,
                      builder: (context, selectedDates, child) {
                        final tooltip = widget.tooltipBuilder?.call(date);
                        final data = _dateData(date);
                        final child = Center(
                          child: BodyLarge(
                            date.day.toString(),
                          ).color(data.textColor),
                        );

                        return InkWell(
                          key: ValueKey(date),
                          onTap: () => _onChangeDate(date),
                          child: TooltipVisibility(
                            visible: tooltip.isNotBlank,
                            child: Tooltip(
                              message: tooltip ?? '',
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (data.isRangeStart || data.isRangeEnd || data.isBetweenRange)
                                    Align(
                                      alignment: data.isBetweenRange
                                          ? Alignment.center
                                          : data.isRangeStart
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                      child: Container(
                                        height: 40,
                                        width: data.isBetweenRange ? 60 : 30,
                                        decoration: BoxDecoration(
                                          color: context.colorScheme.primary.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: data.borderColor),
                                      color: data.backgroundColor,
                                    ),
                                    child: widget.dayBuilder?.call(child, date) ?? child,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
