import 'package:flutter/material.dart';

class AppAction<M extends Object> {
  final String label;
  final Widget icon;
  final void Function()? onPressed;
  final String? tooltip;

  const AppAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });
}

class AppActionDivider<M extends Object> extends AppAction<M> {
  AppActionDivider()
      : super(
          label: '',
          icon: const SizedBox(),
        );
}

class AppActionsGroup<M extends Object> extends AppAction<M> {
  final List<AppAction<M>> items;

  const AppActionsGroup({
    required super.label,
    required super.icon,
    required this.items,
  });
}

extension AppActionListExtension<M extends Object> on List<AppAction<M>> {
  List<Widget> toAnchorChildren() {
    return map((action) {
      return switch (action) {
        AppActionDivider() => const Divider(),
        final AppActionsGroup group => SubmenuButton(
            menuChildren: group.items.toAnchorChildren(),
            leadingIcon: group.icon,
            child: Text(group.label),
          ),
        final AppAction action => TooltipVisibility(
            visible: action.tooltip != null,
            child: Tooltip(
              message: action.tooltip ?? action.label,
              child: MenuItemButton(
                onPressed: action.onPressed,
                leadingIcon: action.icon,
                child: Text(action.label),
              ),
            ),
          ),
      };
    }).toList();
  }
}
