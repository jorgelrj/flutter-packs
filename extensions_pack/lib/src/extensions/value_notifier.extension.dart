import 'package:flutter/material.dart';

extension ValueNotifierExtension<T> on ValueNotifier<List<T>> {
  T? get firstOrNull => value.firstOrNull;
}
