import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WPWidgetsConfig extends Equatable {
  final WPVideoPlayerConfig? videoPlayer;
  final WPDropdownInputConfig? dropdownInput;

  const WPWidgetsConfig({
    this.videoPlayer,
    this.dropdownInput,
  });

  @override
  List<Object?> get props => [videoPlayer, dropdownInput];
}

class WPVideoPlayerConfig extends Equatable {
  final bool showControls;
  final Map<String, String>? headers;

  const WPVideoPlayerConfig({
    this.showControls = true,
    this.headers,
  });

  @override
  List<Object?> get props => [
        showControls,
        headers,
      ];
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
  final ({String short, String long}) rowsPerPage;
  final String of;

  const WPTableStringsConfig({
    required this.noItemsFound,
    required this.itemsSelected,
    required this.rowsPerPage,
    required this.of,
  });

  factory WPTableStringsConfig.defaultConfig() {
    return WPTableStringsConfig(
      noItemsFound: 'No items found',
      itemsSelected: (int count) => '$count selected',
      rowsPerPage: (short: 'Rows', long: 'Rows per page'),
      of: 'of',
    );
  }

  @override
  List<Object?> get props => [noItemsFound];
}

class WPDropdownInputConfig extends Equatable {
  final Color? barrierColor;

  const WPDropdownInputConfig({
    required this.barrierColor,
  });

  @override
  List<Object?> get props => [barrierColor];
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
