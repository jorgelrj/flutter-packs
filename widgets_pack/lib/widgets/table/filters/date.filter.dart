part of '../table_widget.dart';

class _OverlayPortalController extends OverlayPortalController {
  final VoidCallback? onHide;

  _OverlayPortalController({
    this.onHide,
  });

  @override
  void hide() {
    super.hide();
    onHide?.call();
  }
}

class AppDateFilterResult extends Equatable {
  final DateTime? start;
  final DateTime? end;

  const AppDateFilterResult({
    required this.start,
    required this.end,
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
  final String label;
  final ValueChanged<AppDateFilterResult> onChanged;
  final AppDateFilterResult? initialValue;
  final bool allowRange;

  const AppDateFilter({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.allowRange = false,
    super.key,
  });

  @override
  State<AppFilter<M>> createState() => _AppDateFilterState<M>();
}

class _AppDateFilterState<M extends Object> extends _AppFilterState<M> {
  @override
  AppDateFilter<M> get widget => super.widget as AppDateFilter<M>;

  late final _startDateNotifier = ValueNotifier<DateTime?>(
    widget.initialValue?.start,
  );

  late final _endDateNotifier = ValueNotifier<DateTime?>(
    widget.initialValue?.end,
  );

  late final _textController = TextEditingController(
    text: _formattedDate,
  );

  late final _overlayController = _OverlayPortalController(
    onHide: _setValue,
  );

  final _link = LayerLink();

  String get _formattedDate {
    if (_startDateNotifier.value == null) {
      return '';
    }

    return [
      DateFormat('dd/MM/yyyy').format(_startDateNotifier.value!),
      if (widget.allowRange && _endDateNotifier.value != null) DateFormat('dd/MM/yyyy').format(_endDateNotifier.value!),
    ].join(' - ');
  }

  void _dateNotifierListener() {
    _textController.text = _formattedDate;
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
    context.maybeController<M>()?.reload();
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
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: Alignment.topLeft,
              child: ValueListenableBuilder<DateTime?>(
                valueListenable: _startDateNotifier,
                builder: (context, startDate, child) {
                  final hasStartDate = startDate != null;
                  final allowEndDate = widget.allowRange;

                  return SizedBox(
                    width: hasStartDate && allowEndDate ? 600 : 300,
                    child: TapRegion(
                      onTapOutside: (_) => _overlayController.hide(),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CalendarDatePicker(
                                initialDate: _startDateNotifier.value ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2025),
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
                                      lastDate: DateTime(2025),
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
            ),
          );
        },
        child: ListenableBuilder(
          listenable: _textController,
          builder: (context, child) {
            final hasText = _textController.text.isNotEmpty;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const Spacing(),
                  Flexible(
                    child: Text(
                      [
                        widget.label,
                        if (hasText) _textController.text,
                      ].join(': '),
                    ),
                  ),
                ],
              ),
              selected: hasText,
              showCheckmark: false,
              deleteIconColor: context.colorScheme.onPrimary,
              onSelected: (_) {
                _overlayController.show();
              },
              onDeleted: hasText
                  ? () {
                      _startDateNotifier.value = null;
                      _endDateNotifier.value = null;
                      _setValue();
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
