import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widgets_pack/widgets_pack.dart';

class DateRangeFilterOption {
  final String label;
  final DateRange range;

  const DateRangeFilterOption({
    required this.label,
    required this.range,
  });
}

class AppDateRangeFilter extends StatefulWidget {
  final List<DateRangeFilterOption> options;
  final DateRange? initialRange;
  final Date startDate;
  final Date endDate;
  final int? maxRangeDurationInDays;
  final ValueChanged<DateRange>? onChanged;

  const AppDateRangeFilter({
    required this.options,
    required this.startDate,
    required this.endDate,
    this.initialRange,
    this.maxRangeDurationInDays,
    this.onChanged,
    super.key,
  });

  @override
  State<AppDateRangeFilter> createState() => _AppDateRangeFilterState();
}

class _AppDateRangeFilterState extends State<AppDateRangeFilter> {
  late final _rangeNotifier = ValueNotifier<DateRange?>(widget.initialRange);

  late final _displayNotifier = ValueNotifier<(Date?, DateRange?)>((null, widget.initialRange));

  late final _overlayController = AppOverlayPortalController(
    onHide: () {
      _optionNotifier.value = 0;
      _displayNotifier.value = (null, _rangeNotifier.value);
    },
  );

  final _optionNotifier = ValueNotifier<int>(0);
  final _chipKey = GlobalKey();
  final _centerCalendarKey = UniqueKey();
  final _scrollController = ScrollController();

  String get _label {
    final range = _rangeNotifier.value;

    if (range == null) {
      return 'Choose a date range';
    }

    return [
      range.start.formated(),
      range.end.formated(),
    ].join(' - ');
  }

  Offset? _getOffset() {
    final renderBox = _chipKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    }

    final position = renderBox.localToGlobal(Offset.zero);

    return Offset(
      position.dx,
      position.dy + renderBox.size.height + 8,
    );
  }

  Date get _lastDate {
    if (widget.maxRangeDurationInDays != null && _displayNotifier.value.$1 != null) {
      return _displayNotifier.value.$1!.addDays(widget.maxRangeDurationInDays!);
    }

    return widget.endDate;
  }

  void _handleDateSelected(Date date) {
    final display = _displayNotifier.value;

    if (display.$1 == null) {
      _displayNotifier.value = (date, null);

      return;
    }

    final selectedDate = display.$1!;

    if (date.isBefore(selectedDate)) {
      _displayNotifier.value = (date, null);

      return;
    }

    final range = DateRange(
      start: display.$1!,
      end: date,
    );

    _displayNotifier.value = (null, range);
  }

  @override
  void dispose() {
    _rangeNotifier.dispose();
    _displayNotifier.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.targetsRootOverlay(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        final position = _getOffset();

        if (position == null) {
          return const SizedBox();
        }

        return Positioned(
          top: position.dy,
          left: position.dx,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 360 * 2,
              maxHeight: 524,
            ),
            child: TapRegion(
              onTapOutside: (_) => _overlayController.hide(),
              child: Card(
                color: context.colorScheme.surfaceContainerHigh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: kXSAll,
                      child: BodyLarge('Select a date range'),
                    ),
                    const Divider(height: 0),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder<int>(
                                  valueListenable: _optionNotifier,
                                  builder: (context, option, child) {
                                    return ListTile(
                                      title: const Text('Custom'),
                                      trailing: const Icon(Icons.arrow_right),
                                      selected: option == 0,
                                      onTap: () {
                                        _optionNotifier.value = 0;
                                        _displayNotifier.value = (null, null);
                                      },
                                    );
                                  },
                                ),
                                for (final (index, option) in widget.options.indexed)
                                  ValueListenableBuilder<int>(
                                    valueListenable: _optionNotifier,
                                    builder: (context, optionIndex, child) {
                                      return ListTile(
                                        title: Text(option.label),
                                        selected: index + 1 == optionIndex,
                                        onTap: () {
                                          _optionNotifier.value = index + 1;
                                          _displayNotifier.value = (null, option.range);
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: kXSVertical,
                                  child: Row(
                                    children: List<Widget>.generate(7, (index) {
                                      return Center(
                                        child: BodyLarge(
                                          ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                                        ),
                                      );
                                    }).expanded(),
                                  ),
                                ),
                                Expanded(
                                  child: CustomScrollView(
                                    anchor: 0.1,
                                    center: _centerCalendarKey,
                                    controller: _scrollController,
                                    slivers: [
                                      SliverList.builder(
                                        itemBuilder: (context, index) {
                                          return ValueListenableBuilder<(Date?, DateRange?)>(
                                            valueListenable: _displayNotifier,
                                            builder: (context, display, child) {
                                              return _Calendar(
                                                selectedFirstDate: display.$1,
                                                selectedRange: display.$2,
                                                firstDate: widget.startDate,
                                                lastDate: _lastDate,
                                                onDateSelected: _handleDateSelected,
                                                monthAndYear: MonthAndYear.fromDateTime(
                                                  DateTime.now(),
                                                ).subtractMonths(index + 1),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      SliverToBoxAdapter(
                                        key: _centerCalendarKey,
                                        child: ValueListenableBuilder<(Date?, DateRange?)>(
                                          valueListenable: _displayNotifier,
                                          builder: (context, display, child) {
                                            return _Calendar(
                                              selectedFirstDate: display.$1,
                                              selectedRange: display.$2,
                                              firstDate: widget.startDate,
                                              lastDate: _lastDate,
                                              onDateSelected: _handleDateSelected,
                                              monthAndYear: MonthAndYear.fromDateTime(
                                                DateTime.now(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SliverList.builder(
                                        itemBuilder: (context, index) {
                                          return ValueListenableBuilder<(Date?, DateRange?)>(
                                            valueListenable: _displayNotifier,
                                            builder: (context, display, child) {
                                              return _Calendar(
                                                selectedFirstDate: display.$1,
                                                selectedRange: display.$2,
                                                firstDate: widget.startDate,
                                                lastDate: _lastDate,
                                                onDateSelected: _handleDateSelected,
                                                monthAndYear: MonthAndYear.fromDateTime(
                                                  DateTime.now(),
                                                ).addMonths(index + 1),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    Padding(
                      padding: kXXSAll,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton.text(
                            onPressed: _overlayController.hide,
                            child: const Text('Cancel'),
                          ),
                          ValueListenableBuilder<(Date?, DateRange?)>(
                            valueListenable: _displayNotifier,
                            builder: (context, display, child) {
                              final range = display.$2;

                              return AppButton.text(
                                onPressed: range != null && range != _rangeNotifier.value
                                    ? () {
                                        _rangeNotifier.value = range;
                                        widget.onChanged?.call(range);
                                        _overlayController.hide();
                                      }
                                    : null,
                                child: const Text('Apply'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: FilterChip(
        key: _chipKey,
        selected: true,
        showCheckmark: false,
        avatar: const Icon(Icons.date_range),
        label: ValueListenableBuilder<DateRange?>(
          valueListenable: _rangeNotifier,
          builder: (context, range, _) {
            return Text(_label);
          },
        ),
        onSelected: (_) => _overlayController.toggle(),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  final MonthAndYear monthAndYear;
  final DateRange? selectedRange;
  final Date? selectedFirstDate;
  final ValueChanged<Date> onDateSelected;
  final Date firstDate;
  final Date lastDate;

  const _Calendar({
    required this.monthAndYear,
    required this.onDateSelected,
    required this.firstDate,
    required this.lastDate,
    this.selectedFirstDate,
    this.selectedRange,
  });

  ({
    Color borderColor,
    Color backgroundColor,
    Color textColor,
    bool isRangeStart,
    bool isRangeEnd,
    bool isBetweenRange,
    bool disabled,
  }) _dateData(BuildContext context, Date date) {
    final isSelected = selectedRange == null && (selectedFirstDate == date);
    final isToday = date.isToday;

    final isDisabled = date != firstDate && date < firstDate || date != lastDate && date > lastDate;

    final isRangeStart = selectedRange?.start == date;
    final isRangeEnd = selectedRange?.end == date;

    final isBetweenRange = selectedRange != null && date > selectedRange!.start && date < selectedRange!.end;

    return (
      disabled: isDisabled,
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
  Widget build(BuildContext context) {
    final daysInMonth = monthAndYear.toDateTime().daysInMonth;
    final gridCount = daysInMonth + monthAndYear.toDateTime().weekDayBaseSunday;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLarge(
          monthAndYear.toDateTime().formatBy(
                DateFormat('MMMM'),
              ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            final firstWeekDay = monthAndYear.toDateTime().weekDayBaseSunday;

            if (index < firstWeekDay || index >= daysInMonth + firstWeekDay) {
              return const SizedBox();
            }

            final date = Date(
              monthAndYear.year,
              monthAndYear.month,
              index - firstWeekDay + 1,
            );

            final data = _dateData(context, date);

            return Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                key: ValueKey(date),
                onTap: data.disabled ? null : () => onDateSelected(date),
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
                      child: Center(
                        child: BodyLarge(
                          date.day.toString(),
                        ).color(data.textColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
