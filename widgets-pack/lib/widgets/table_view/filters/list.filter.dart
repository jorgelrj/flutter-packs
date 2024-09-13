part of 'filter.dart';

class AppListFilter<T extends Object> extends StatefulWidget {
  final List<T> items;
  final String label;
  final ValueChanged<T?> onChanged;
  final T? initialValue;

  const AppListFilter({
    required this.label,
    required this.onChanged,
    required this.items,
    this.initialValue,
    super.key,
  });

  @override
  State<AppListFilter> createState() => _AppListFilterState();
}

class _AppListFilterState extends State<AppListFilter> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
