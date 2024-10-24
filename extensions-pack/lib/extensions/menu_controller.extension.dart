import 'package:flutter/material.dart';

extension MenuControllerExtension on MenuController {
  void toggle() => isOpen ? close() : open();
}
