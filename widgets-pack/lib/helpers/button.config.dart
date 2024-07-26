import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppButtonType {
  filled,
  outlined,
  text,
  elevated,
  tonal,
  icon;

  bool get isFilled => this == AppButtonType.filled;
  bool get isIcon => this == AppButtonType.icon;
}

class AppButtonConfig extends Equatable {
  final String? _title;
  final Widget? _child;
  final AppButtonType type;

  final FutureOr<void> Function()? onPressed;
  final FutureOr<void> Function()? onPressedDisabled;
  final bool popFirst;
  final int flex;

  const AppButtonConfig({
    required Widget child,
    this.onPressed,
    this.onPressedDisabled,
    this.popFirst = false,
    this.flex = 1,
    this.type = AppButtonType.elevated,
  })  : _title = null,
        _child = child;

  const AppButtonConfig.text(
    String title, {
    this.onPressed,
    this.onPressedDisabled,
    this.popFirst = false,
    this.flex = 1,
    this.type = AppButtonType.elevated,
  })  : _title = title,
        _child = null;

  const AppButtonConfig.child(
    Widget child, {
    this.onPressed,
    this.onPressedDisabled,
    this.popFirst = false,
    this.flex = 1,
    this.type = AppButtonType.elevated,
  })  : _child = child,
        _title = null;

  @override
  List<Object?> get props => [
        _title,
        _child,
        onPressedDisabled,
        popFirst,
        flex,
        onPressed,
        type,
      ];

  Widget get child => _child ?? Text(_title!);

  AppButtonConfig copyWith({
    Widget? child,
    AppButtonType? type,
    FutureOr<void> Function()? onPressed,
    FutureOr<void> Function()? onPressedDisabled,
    bool? popFirst,
    int? flex,
  }) {
    return AppButtonConfig(
      child: child ?? this.child,
      type: type ?? this.type,
      onPressed: onPressed ?? this.onPressed,
      onPressedDisabled: onPressedDisabled ?? this.onPressedDisabled,
      popFirst: popFirst ?? this.popFirst,
      flex: flex ?? this.flex,
    );
  }
}
