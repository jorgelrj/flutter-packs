import 'package:flutter/material.dart';

extension ColorExtension on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) {
    return '${leadingHashSign ? '#' : ''}'
        '${alphaChannel.toRadixString(16).padLeft(2, '0')}'
        '${redChannel.toRadixString(16).padLeft(2, '0')}'
        '${greenChannel.toRadixString(16).padLeft(2, '0')}'
        '${blueChannel.toRadixString(16).padLeft(2, '0')}';
  }

  int get alphaChannel => (a * 255.0).round() & 0xff;

  int get redChannel => (r * 255.0).round() & 0xff;

  int get greenChannel => (g * 255.0).round() & 0xff;

  int get blueChannel => (b * 255.0).round() & 0xff;

  Color applyOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
