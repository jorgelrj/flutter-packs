import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WPWidgetsConfig extends Equatable {
  final Map<String, String>? videoPlayerCustomHeaders;

  const WPWidgetsConfig({
    this.videoPlayerCustomHeaders,
  });

  @override
  List<Object?> get props => [videoPlayerCustomHeaders];
}

class WPStringsConfig extends Equatable {
  final WPTableStringsConfig table;

  WPStringsConfig({
    WPTableStringsConfig? table,
  }) : table = table ?? WPTableStringsConfig.defaultConfig();

  @override
  List<Object?> get props => [table];
}

class WPTableStringsConfig extends Equatable {
  final String noItemsFound;
  final String Function(int) itemsSelected;

  const WPTableStringsConfig({
    required this.noItemsFound,
    required this.itemsSelected,
  });

  factory WPTableStringsConfig.defaultConfig() {
    return WPTableStringsConfig(
      noItemsFound: 'No items found',
      itemsSelected: (int count) => '$count selected',
    );
  }

  @override
  List<Object?> get props => [noItemsFound];
}

class WidgetsPackProvider extends StatefulWidget {
  final Widget child;
  final WPStringsConfig? stringsConfig;
  final WPWidgetsConfig? widgetsConfig;

  const WidgetsPackProvider({
    required this.child,
    this.stringsConfig,
    this.widgetsConfig,
    super.key,
  });

  @override
  State<WidgetsPackProvider> createState() => _WidgetsPackProviderState();

  static _WidgetsPackProviderState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<_WidgetsPackProviderState>();
  }
}

class _WidgetsPackProviderState extends State<WidgetsPackProvider> {
  WPWidgetsConfig? get widgetsConfig => widget.widgetsConfig;

  WPStringsConfig? get stringsConfig => widget.stringsConfig;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension WidgetsPackProviderExtension on BuildContext {
  WPWidgetsConfig get wpWidgetsConfig {
    return WidgetsPackProvider.maybeOf(this)?.widgetsConfig ?? const WPWidgetsConfig();
  }

  WPStringsConfig get wpStringsConfig {
    return WidgetsPackProvider.maybeOf(this)?.stringsConfig ?? WPStringsConfig();
  }
}
