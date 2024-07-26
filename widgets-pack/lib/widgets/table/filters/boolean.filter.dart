part of '../table_widget.dart';

class AppBooleanFilter<M extends Object> extends AppFilter<M> {
  final String label;
  final ValueChanged<bool?> onChanged;
  final bool? initialValue;
  final bool triState;

  const AppBooleanFilter({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.triState = false,
    super.key,
  });

  @override
  State<AppFilter<M>> createState() => _AppBooleanFilterState<M>();
}

class _AppBooleanFilterState<M extends Object> extends _AppFilterState<M> {
  @override
  AppBooleanFilter<M> get widget => super.widget as AppBooleanFilter<M>;

  final _changeDebouncer = Debouncer(duration: const Duration(seconds: 1));

  late bool? _value = widget.initialValue;

  bool? get _nextValue {
    if (_value == null) {
      return true;
    } else if (_value == true && widget.triState) {
      return false;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selected: _value != null,
      showCheckmark: _value == true,
      avatar: _value == false ? const Icon(Icons.remove) : null,
      onSelected: (bool value) {
        setState(() => _value = _nextValue);
        _changeDebouncer.run(() {
          widget.onChanged(_value);
          context.maybeController<M>()?.reload();
        });
      },
    );
  }
}
