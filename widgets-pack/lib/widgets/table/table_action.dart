import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/helpers/helpers.dart';
import 'package:widgets_pack/widgets/widgets.dart';

class AppTableActionsRow<M extends Object> extends StatelessWidget {
  final List<M> items;
  final TableActionFn<M>? actions;
  final VoidCallback onClearAll;
  final String Function(int)? itemsSelectedTextBuilder;

  const AppTableActionsRow({
    required this.items,
    required this.actions,
    required this.onClearAll,
    this.itemsSelectedTextBuilder,
    super.key,
  });

  Widget _buildAction(AppAction<M> action) {
    if (action is AppActionDivider<M>) {
      return const VerticalDivider(
        indent: 8,
        endIndent: 8,
      );
    }

    if (action is AppActionsGroup<M>) {
      return MenuAnchor(
        menuChildren: [
          ...action.items.map(
            (item) {
              return MenuItemButton(
                onPressed: item.onPressed,
                leadingIcon: item.icon,
                child: Text(item.label),
              );
            },
          ),
        ],
        builder: (context, controller, child) {
          return AppButton.icon(
            onPressed: controller.open,
            tooltip: action.label,
            icon: action.icon,
          );
        },
      );
    }

    return AppButton.icon(
      onPressed: action.onPressed,
      tooltip: action.label,
      icon: action.icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _strings = context.wpStringsConfig.table;
    Iterable<Widget> actionsWidgets = actions?.call(items).map(_buildAction) ?? [];

    if (actionsWidgets.firstOrNull is VerticalDivider) {
      actionsWidgets = actionsWidgets.skip(1);
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: <Widget>[
          AppButton.icon(
            onPressed: onClearAll,
            icon: const Icon(Icons.close),
          ),
          TitleSmall(
            itemsSelectedTextBuilder?.call(items.length) ?? _strings.itemsSelected(items.length),
          ),
          if (actionsWidgets.isNotEmpty)
            const VerticalDivider(
              indent: 8,
              endIndent: 8,
            ),
          ...actionsWidgets,
        ].addSpacingBetween(),
      ),
    );
  }
}
