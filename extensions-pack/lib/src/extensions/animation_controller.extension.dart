import 'package:flutter/material.dart';

extension AnimationControllerExtension on AnimationController {
  Future<void> toggle() async {
    if (isAnimating) {
      return;
    }

    if (isCompleted) {
      return reverse();
    } else {
      return forward();
    }
  }
}
