part of 'table_widget.dart';

class _AppTableFilterRow extends StatelessWidget {
  final AppButtonConfig? headerAction;
  final String? headerTitle;
  final List<Widget> filters;

  const _AppTableFilterRow({
    this.headerAction,
    this.headerTitle,
    this.filters = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(minHeight: 46),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Wrap(
              runAlignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (filters.isNotEmpty)
                  ...filters
                else if (headerTitle != null)
                  Text(
                    headerTitle!,
                    style: context.textTheme.headlineSmall,
                  ),
              ],
            ),
          ),
          if (headerAction != null) AppButton.fromConfig(headerAction!),
        ].addSpacingBetween(),
      ),
    );
  }
}

sealed class AppFilter<M extends Object> extends StatefulWidget {
  const AppFilter({super.key});

  @override
  State<AppFilter<M>> createState();
}

sealed class _AppFilterState<M extends Object> extends State<AppFilter<M>> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
