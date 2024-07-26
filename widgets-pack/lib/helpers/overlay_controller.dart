import 'package:flutter/material.dart';

class AppOverlayPortalController extends OverlayPortalController {
  final VoidCallback? onHide;

  AppOverlayPortalController({
    this.onHide,
  });

  @override
  void hide() {
    super.hide();

    onHide?.call();
  }
}
