import 'dart:async';

import 'package:flutter/material.dart';

class SubmenuSettings {
  final bool closeOnActivate;

  const SubmenuSettings({
    this.closeOnActivate = true,
  });
}

class AppAction<M extends Object> {
  final String label;
  final Widget? icon;
  final Widget Function()? iconCallback;
  final void Function()? onPressed;
  final String? tooltip;
  final String? disabledTooltip;
  final TextStyle? style;
  final SubmenuSettings? submenuSettings;
  final FutureOr<bool> Function()? enabledCallback;

  const AppAction({
    required this.label,
    this.icon,
    this.iconCallback,
    this.onPressed,
    this.tooltip,
    this.disabledTooltip,
    this.style,
    this.submenuSettings,
    this.enabledCallback,
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
          leadingIcon: group.iconCallback?.call() ?? group.icon,
          child: Text(group.label, style: group.style),
        ),
      final AppAction action => TooltipVisibility(
          visible: action.tooltip != null || action.disabledTooltip != null,
          child: FutureBuilder(
            future: Future.value(action.enabledCallback?.call() ?? true),
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;

              return Tooltip(
                message: (enabled ? action.tooltip : action.disabledTooltip) ?? action.label,
                child: MenuItemButton(
                  onPressed: enabled ? action.onPressed : null,
                  leadingIcon: action.iconCallback?.call() ?? action.icon,
                  closeOnActivate: action.submenuSettings?.closeOnActivate ?? true,
                  child: Text(action.label, style: action.style),
                ),
              );
            },
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
