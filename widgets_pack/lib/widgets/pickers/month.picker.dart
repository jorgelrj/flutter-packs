import 'package:flutter/material.dart';
import 'package:widgets_pack/helpers/helpers.dart';

class AppMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const AppMonthPicker._({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  static Future<MonthAndYear?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDialog<MonthAndYear>(
      context: context,
      builder: (context) {
        return AppMonthPicker._(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );
      },
    );
  }

  @override
  State<AppMonthPicker> createState() => _AppMonthPickerState();
}

class _AppMonthPickerState extends State<AppMonthPicker> with RestorationMixin {
  late final RestorableDateTimeN _selectedDate = RestorableDateTimeN(widget.initialDate);

  static const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
  static const double _kMaxTextScaleFactor = 1.3;
  static const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);

  @override
  String? get restorationId => 'app_month_picker';

  void _handleOk() {
    final date = _selectedDate.value;

    Navigator.pop(
      context,
      date != null ? MonthAndYear(month: date.month, year: date.year) : null,
    );
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleDateChanged(DateTime date) {
    setState(() {
      _selectedDate.value = date;
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
  }

  @override
  void dispose() {
    _selectedDate.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datePickerTheme = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);
    final localizations = MaterialLocalizations.of(context);

    final double textScaleFactor =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: _kMaxTextScaleFactor).textScaleFactor;
    final dialogSize = _calendarLandscapeDialogSize * textScaleFactor;

    final Widget header = _DatePickerHeader(
      helpText: localizations.datePickerHelpText,
      titleText: _selectedDate.value == null ? '' : localizations.formatMonthYear(_selectedDate.value!),
      titleStyle: datePickerTheme.headerHeadlineStyle ?? defaults.headerHeadlineStyle,
      orientation: Orientation.landscape,
      isShort: true,
    );

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            style: datePickerTheme.cancelButtonStyle ?? defaults.cancelButtonStyle,
            onPressed: _handleCancel,
            child: Text(
              localizations.cancelButtonLabel,
            ),
          ),
          TextButton(
            style: datePickerTheme.confirmButtonStyle ?? defaults.confirmButtonStyle,
            onPressed: _handleOk,
            child: Text(localizations.okButtonLabel),
          ),
        ],
      ),
    );

    final Widget picker = _Picker(
      initialDate: widget.initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      currentDate: _selectedDate.value ?? widget.initialDate,
      onChanged: _handleDateChanged,
    );

    return Dialog(
      backgroundColor: datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: datePickerTheme.elevation ?? defaults.elevation ?? 24,
      shadowColor: datePickerTheme.shadowColor ?? defaults.shadowColor,
      surfaceTintColor: datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor,
      shape: datePickerTheme.shape ?? defaults.shape,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _kMaxTextScaleFactor,
          child: Row(
            children: [
              header,
              VerticalDivider(width: 0, color: datePickerTheme.dividerColor),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(child: picker),
                    actions,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerHeader extends StatelessWidget {
  /// Creates a header for use in a date picker dialog.
  const _DatePickerHeader({
    required this.helpText,
    required this.titleText,
    required this.titleStyle,
    required this.orientation,
    this.isShort = false,
  });

  static const double _datePickerHeaderLandscapeWidth = 152.0;
  static const double _datePickerHeaderPortraitHeight = 120.0;
  static const double _headerPaddingLandscape = 16.0;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String helpText;

  /// The text that is displayed at the center of the header.
  final String titleText;

  /// The [TextStyle] that the title text is displayed with.
  final TextStyle? titleStyle;

  /// The orientation is used to decide how to layout its children.
  final Orientation orientation;

  /// Indicates the header is being displayed in a shorter/narrower context.
  ///
  /// This will be used to tighten up the space between the help text and date
  /// text if `true`. Additionally, it will use a smaller typography style if
  /// `true`.
  ///
  /// This is necessary for displaying the manual input mode in
  /// landscape orientation, in order to account for the keyboard height.
  final bool isShort;

  @override
  Widget build(BuildContext context) {
    final DatePickerThemeData themeData = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final Color? backgroundColor = themeData.headerBackgroundColor ?? defaults.headerBackgroundColor;
    final Color? foregroundColor = themeData.headerForegroundColor ?? defaults.headerForegroundColor;
    final TextStyle? helpStyle = (themeData.headerHelpStyle ?? defaults.headerHelpStyle)?.copyWith(
      color: foregroundColor,
    );

    final Text help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final Text title = Text(
      titleText,
      semanticsLabel: titleText,
      style: titleStyle,
      maxLines: orientation == Orientation.portrait ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );

    switch (orientation) {
      case Orientation.portrait:
        return SizedBox(
          height: _datePickerHeaderPortraitHeight,
          child: Material(
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 24,
                end: 12,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  help,
                  const Flexible(child: SizedBox(height: 38)),
                  title,
                ],
              ),
            ),
          ),
        );
      case Orientation.landscape:
        return SizedBox(
          width: _datePickerHeaderLandscapeWidth,
          child: Material(
            color: backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _headerPaddingLandscape,
                  ),
                  child: help,
                ),
                SizedBox(height: isShort ? 16 : 56),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _headerPaddingLandscape,
                    ),
                    child: title,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _Picker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onChanged;

  const _Picker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onChanged,
  });

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  static const double _subHeaderHeight = 52.0;

  late final _monthYearNotifier = ValueNotifier<MonthAndYear>(
    MonthAndYear.fromDateTime(widget.initialDate),
  );

  void _handleOnNextYear() {
    final current = _monthYearNotifier.value;
    final next = current.copyWith(year: current.year + 1);

    _monthYearNotifier.value = next;
  }

  void _handleOnPreviousYear() {
    final current = _monthYearNotifier.value;
    final previous = current.copyWith(year: current.year - 1);

    _monthYearNotifier.value = previous;
  }

  @override
  Widget build(BuildContext context) {
    final Color controlColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.60);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<MonthAndYear>(
      valueListenable: _monthYearNotifier,
      builder: (context, current, child) {
        final showingFirstYear = current.year == widget.firstDate.year;
        final showingLastYear = current.year == widget.lastDate.year;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
              height: _subHeaderHeight,
              child: Row(
                children: [
                  Text(
                    current.year.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: controlColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: showingFirstYear ? null : _handleOnPreviousYear,
                    color: controlColor,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: showingLastYear ? null : _handleOnNextYear,
                    color: controlColor,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Flexible(
              child: GridView.builder(
                key: ValueKey(current),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: DateTime.monthsPerYear,
                itemBuilder: (context, index) {
                  final month = current.copyWith(month: index + 1);

                  return _MonthButton(
                    date: month,
                    isDisabled: month.isBefore(MonthAndYear.fromDateTime(widget.firstDate)) ||
                        month.isAfter(MonthAndYear.fromDateTime(widget.lastDate)),
                    isSelectedDay: month == MonthAndYear.fromDateTime(widget.currentDate),
                    onChanged: (date) {
                      _monthYearNotifier.value = date;
                      widget.onChanged(date.monthStart);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MonthButton extends StatefulWidget {
  final MonthAndYear date;
  final ValueChanged<MonthAndYear> onChanged;
  final bool isDisabled;
  final bool isSelectedDay;

  const _MonthButton({
    required this.date,
    required this.onChanged,
    required this.isDisabled,
    required this.isSelectedDay,
  });

  @override
  State<_MonthButton> createState() => _MonthButtonState();
}

class _MonthButtonState extends State<_MonthButton> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const double _dayPickerRowHeight = 42.0;

  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  Widget build(BuildContext context) {
    final datePickerTheme = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);
    final TextStyle? dayStyle = datePickerTheme.dayStyle ?? defaults.dayStyle;

    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) {
      return getProperty(datePickerTheme) ?? getProperty(defaults);
    }

    T? resolve<T>(
      WidgetStateProperty<T>? Function(DatePickerThemeData? theme) getProperty,
      Set<WidgetState> states,
    ) {
      return effectiveValue(
        (DatePickerThemeData? theme) {
          return getProperty(theme)?.resolve(states);
        },
      );
    }

    final Set<WidgetState> states = <WidgetState>{
      if (widget.isDisabled) WidgetState.disabled,
      if (widget.isSelectedDay) WidgetState.selected,
    };

    _statesController.value = states;

    final Color? dayForegroundColor = resolve<Color?>(
      (DatePickerThemeData? theme) =>
          widget.date.isCurrentMonthAndYear ? theme?.todayForegroundColor : theme?.dayForegroundColor,
      states,
    );
    final Color? dayBackgroundColor = resolve<Color?>(
      (DatePickerThemeData? theme) =>
          widget.date.isCurrentMonthAndYear ? theme?.todayBackgroundColor : theme?.dayBackgroundColor,
      states,
    );

    final WidgetStateProperty<Color?> dayOverlayColor = WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) => effectiveValue(
        (DatePickerThemeData? theme) => theme?.dayOverlayColor?.resolve(states),
      ),
    );

    final BoxDecoration decoration = widget.date.isCurrentMonthAndYear
        ? BoxDecoration(
            color: dayBackgroundColor,
            border: Border.fromBorderSide(
              (datePickerTheme.todayBorder ?? defaults.todayBorder!).copyWith(color: dayForegroundColor),
            ),
            shape: BoxShape.circle,
          )
        : BoxDecoration(
            color: dayBackgroundColor,
            shape: BoxShape.circle,
          );

    return InkResponse(
      onTap: widget.isDisabled ? null : () => widget.onChanged(widget.date),
      radius: _dayPickerRowHeight / 2 + 4,
      statesController: _statesController,
      overlayColor: dayOverlayColor,
      child: Container(
        decoration: decoration,
        child: Center(
          child: Text(
            _months[widget.date.month - 1].substring(0, 3),
            style: dayStyle?.apply(color: dayForegroundColor),
          ),
        ),
      ),
    );
  }
}
