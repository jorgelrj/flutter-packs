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

  Widget _buildAction(AppAction<M> action, [bool useSubGroups = false]) {
    if (action is AppActionDivider<M>) {
      if (useSubGroups) {
        return const Divider();
      }

      return const VerticalDivider(
        indent: 8,
        endIndent: 8,
      );
    }

    if (action is AppActionsGroup<M>) {
      if (useSubGroups) {
        return SubmenuButton(
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
          child: Text(action.label),
        );
      }

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

    if (useSubGroups) {
      return MenuItemButton(
        onPressed: action.onPressed,
        leadingIcon: action.icon,
        child: Text(action.label),
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
    List<AppAction<M>> appActions = actions?.call(items).toList() ?? <AppAction<M>>[];

    if (appActions.firstOrNull is AppActionDivider<M>) {
      appActions = appActions.skip(1).toList();
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
          const VerticalDivider(
            indent: 8,
            endIndent: 8,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxVisibleActions = (constraints.maxWidth - 44) ~/ 44;

                return Row(
                  children: [
                    ...appActions.take(maxVisibleActions).map(_buildAction),
                    if (appActions.length > maxVisibleActions)
                      MenuAnchor(
                        menuChildren: [
                          ...appActions.sublist(maxVisibleActions).map((action) {
                            return _buildAction(action, true);
                          }),
                        ],
                        builder: (context, controller, child) {
                          return AppButton.icon(
                            onPressed: controller.open,
                            tooltip: 'More',
                            icon: const Icon(Icons.more_vert),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          // if (actionsWidgets.isNotEmpty) ...actionsWidgets,
        ].addSpacingBetween(),
      ),
    );
  }
}
