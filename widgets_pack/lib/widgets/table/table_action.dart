import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets/widgets.dart';

class TableAction<M extends Object> {
  final String label;
  final Widget icon;
  final void Function()? onPressed;

  const TableAction({
    required this.label,
    required this.icon,
    this.onPressed,
  });
}

class TableActionDivider<M extends Object> extends TableAction<M> {
  TableActionDivider()
      : super(
          label: '',
          icon: const SizedBox(),
        );
}

class TableAnchorAction<M extends Object> extends TableAction<M> {
  final List<TableAction<M>> items;

  const TableAnchorAction({
    required super.label,
    required super.icon,
    required this.items,
  });
}

class AppTableActionsRow<M extends Object> extends StatelessWidget {
  final List<M> items;
  final TableActionFn<M>? actions;
  final VoidCallback onClearAll;

  const AppTableActionsRow({
    required this.items,
    required this.actions,
    required this.onClearAll,
    super.key,
  });

  Widget _buildAction(TableAction<M> action) {
    if (action is TableActionDivider<M>) {
      return const VerticalDivider(
        indent: 8,
        endIndent: 8,
      );
    }

    if (action is TableAnchorAction<M>) {
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
            _strings.itemsSelected(items.length),
          ),
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
