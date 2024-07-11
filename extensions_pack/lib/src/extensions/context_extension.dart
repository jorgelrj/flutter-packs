import 'package:flutter/material.dart';

extension ContextEPExtension on BuildContext {
  MediaQueryData get mq => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;

  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  Future<void> maybePopRoute<T extends Object?>([T? result]) {
    return Navigator.of(this).maybePop<T>(result);
  }

  Future<void> scrollToTop() async {
    Scrollable.maybeOf(this)?.position.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
  }
}
