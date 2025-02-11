import 'package:flutter/material.dart';

class AppAction<M extends Object> {
  final String label;
  final Widget _icon;
  final void Function()? onPressed;
  final String? tooltip;
  final TextStyle? style;

  const AppAction({
    required this.label,
    Widget? icon,
    this.onPressed,
    this.tooltip,
    this.style,
  }) : _icon = icon ?? const SizedBox();

  Widget get icon => _icon;
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
    required this.items,
    super.icon,
    super.style,
  });
}

class AppActionBuilder<M extends Object> extends AppAction<M> {
  final Widget Function() builder;

  const AppActionBuilder({
    required this.builder,
  }) : super(
          label: '',
          icon: const SizedBox(),
        );
}

extension AppActionExtension<M extends Object> on AppAction<M> {
  Widget toAnchorChild() {
    return switch (this) {
      AppActionDivider() => const Divider(),
      final AppActionBuilder builder => builder.builder(),
      final AppActionsGroup group => SubmenuButton(
          menuChildren: group.items.toAnchorChildren(),
          leadingIcon: group.icon,
          child: Text(group.label, style: group.style),
        ),
      final AppAction action => TooltipVisibility(
          visible: action.tooltip != null,
          child: Tooltip(
            message: action.tooltip ?? action.label,
            child: MenuItemButton(
              onPressed: action.onPressed,
              leadingIcon: action.icon,
              child: Text(action.label, style: action.style),
            ),
          ),
        ),
    };
  }
}

extension AppActionListExtension<M extends Object> on List<AppAction<M>> {
  List<Widget> toAnchorChildren() {
    return map((action) => action.toAnchorChild()).toList();
  }
}
