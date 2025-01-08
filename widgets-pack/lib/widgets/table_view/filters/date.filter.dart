part of 'filter.dart';

class AppDateFilterResult extends Equatable {
  final DateTime? start;
  final DateTime? end;

  const AppDateFilterResult({
    this.start,
    this.end,
  });

  @override
  List<Object?> get props => [start, end];

  DateTimeRange? get range {
    if (start == null || end == null) {
      return null;
    }

    return DateTimeRange(start: start!, end: end!);
  }
}

class AppDateFilter<M extends Object> extends AppFilter<M> {
  final String? label;
  final ValueChanged<AppDateFilterResult> onChanged;
  final AppDateFilterResult? initialValue;
  final bool allowRange;
  final bool allowNullValues;
  final String Function(DateTime)? formatter;
  final bool enabled;
  final Color? overlayBackgroundColor;
  final bool closeOnSelect;

  const AppDateFilter({
    required this.onChanged,
    this.label,
    this.initialValue,
    this.allowRange = false,
    this.allowNullValues = true,
    this.formatter,
    this.enabled = true,
    this.overlayBackgroundColor,
    this.closeOnSelect = false,
    super.key,
  });

  @override
  State<AppFilter<M>> createState() => _AppDateFilterState<M>();
}

class _AppDateFilterState<M extends Object> extends _AppFilterState<M> {
  @override
  AppDateFilter<M> get widget => super.widget as AppDateFilter<M>;

  final _chipKey = GlobalKey<_AppDateFilterState<M>>();

  late final _startDateNotifier = ValueNotifier<DateTime?>(
    widget.initialValue?.start,
  );

  late final _endDateNotifier = ValueNotifier<DateTime?>(
    widget.initialValue?.end,
  );

  late final _textController = TextEditingController(
    text: _formattedDate,
  );

  late final _overlayController = AppOverlayPortalController(
    onHide: _setValue,
  );

  String get _formattedDate {
    if (_startDateNotifier.value == null) {
      return '';
    }

    return [
      _formatDate(_startDateNotifier.value!),
      if (widget.allowRange && _endDateNotifier.value != null) _formatDate(_endDateNotifier.value!),
    ].join(' - ');
  }

  double get _overlayWidth {
    final hasStartDate = _startDateNotifier.value != null;
    final allowEndDate = widget.allowRange;

    return hasStartDate && allowEndDate ? 600 : 300;
  }

  String _formatDate(DateTime date) {
    return widget.formatter?.call(date) ?? DateFormat('dd/MM/yyyy').format(date);
  }

  void _dateNotifierListener() {
    _textController.text = _formattedDate;

    // TODO: Improve this to consider if date range is enabled
    if (widget.closeOnSelect) {
      _setValue();
    }
  }

  void _setValue() {
    widget.onChanged(
      AppDateFilterResult(
        start: _startDateNotifier.value,
        end: _endDateNotifier.value,
      ),
    );
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
    AppTableView.maybeOf(context)?.controller.reload();
  }

  @override
  void initState() {
    super.initState();

    _startDateNotifier.addListener(_dateNotifierListener);
    _endDateNotifier.addListener(_dateNotifierListener);
  }

  @override
  void dispose() {
    _textController.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppDateFilter<M> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      _startDateNotifier.value = widget.initialValue?.start;
      _endDateNotifier.value = widget.initialValue?.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _textController,
      builder: (context, child) {
        final hasText = _textController.text.isNotEmpty;

        return FilterChip(
          key: _chipKey,
          label: OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: (context) {
              final chipBox = _chipKey.currentContext!.findRenderObject() as RenderBox;
              final chipPosition = chipBox.localToGlobal(Offset.zero);
              final topPosition = chipPosition.dy + chipBox.size.height + 16;

              double leftPosition = chipPosition.dx - (_overlayWidth - chipBox.size.width) / 2;
              final overlayOutOfBounds =
                  leftPosition < 0 || (leftPosition + _overlayWidth) > (context.screenSize.width - 24);

              if (overlayOutOfBounds) {
                leftPosition = leftPosition < 0 ? 48 : context.screenSize.width - _overlayWidth - 48;
              }

              return Positioned(
                top: topPosition,
                left: leftPosition,
                child: ValueListenableBuilder<DateTime?>(
                  valueListenable: _startDateNotifier,
                  builder: (context, startDate, child) {
                    final hasStartDate = startDate != null;
                    final allowEndDate = widget.allowRange;

                    return SizedBox(
                      width: _overlayWidth,
                      child: TapRegion(
                        onTapOutside: (_) => _overlayController.hide(),
                        child: Card(
                          color: widget.overlayBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                CalendarDatePicker(
                                  initialDate: _startDateNotifier.value ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now() + const Duration(days: 365 * 5),
                                  onDateChanged: (date) {
                                    _startDateNotifier.value = date;
                                    _endDateNotifier.value = null;
                                  },
                                ),
                                if (allowEndDate && hasStartDate)
                                  ValueListenableBuilder<DateTime?>(
                                    valueListenable: _endDateNotifier,
                                    builder: (context, endDate, child) {
                                      return CalendarDatePicker(
                                        key: ValueKey((startDate, endDate)),
                                        initialDate: _endDateNotifier.value,
                                        firstDate: startDate,
                                        lastDate: DateTime.now() + const Duration(days: 365 * 5),
                                        onDateChanged: (date) {
                                          if (date == _endDateNotifier.value) {
                                            _endDateNotifier.value = null;
                                          } else {
                                            _endDateNotifier.value = date;
                                          }
                                        },
                                      );
                                    },
                                  ),
                              ].flexed(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const Spacing(),
                Flexible(
                  child: Text(
                    [
                      if (widget.label != null) widget.label,
                      if (hasText) _textController.text,
                    ].join(': '),
                  ),
                ),
              ],
            ),
          ),
          selected: hasText,
          showCheckmark: false,
          deleteIconColor: context.colorScheme.onPrimary,
          onSelected: widget.enabled
              ? (_) {
                  _overlayController.show();
                }
              : null,
          onDeleted: hasText && widget.allowNullValues
              ? () {
                  _startDateNotifier.value = null;
                  _endDateNotifier.value = null;
                  _setValue();
                }
              : null,
        );
      },
    );
  }
}
