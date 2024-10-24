import 'dart:math' as math;

import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/services.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class CapitalizeCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.capitalize(),
      selection: newValue.selection,
    );
  }
}

class NumericalRangeTextFormatter extends TextInputFormatter {
  final num min;
  final num max;

  NumericalRangeTextFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = double.tryParse(newValue.text) ?? 0;

    if (newValue.text == '') {
      return newValue;
    } else if (value < min) {
      return TextEditingValue.empty.copyWith(text: min.toStringAsFixed(2));
    } else {
      return value > max ? oldValue : newValue;
    }
  }
}

class MaxLengthTextFormatter extends TextInputFormatter {
  final int maxLength;

  MaxLengthTextFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int max = maxLength;
    final String value = newValue.text;

    if (value.length > max) {
      return oldValue;
    }

    return newValue;
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int? decimalRange;

  DecimalTextInputFormatter(this.decimalRange) : assert(decimalRange == null || decimalRange > 0);

  bool _hasDecimal(String value) {
    return value.contains('.') || value.contains(',');
  }

  int _decimalIndex(String value) {
    return value.contains('.') ? value.indexOf('.') : value.indexOf(',');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      final String value = newValue.text;

      if (_hasDecimal(value) && value.substring(_decimalIndex(value) + 1).length > decimalRange!) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == '.') {
        truncated = '0.';

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
      );
    }

    return newValue;
  }
}

class TrimSpacesTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.replaceAll(RegExp(r'\s+'), ''),
      selection: TextSelection.collapsed(offset: newValue.text.length),
    );
  }
}

class SuffixTextFormatter extends TextInputFormatter {
  final String suffix;

  const SuffixTextFormatter({
    required this.suffix,
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final selection = oldValue.selection;
    final isAllSelected = selection.start == 0 && selection.end == oldValue.text.length;

    if (!isAllSelected) {
      if (newValue.text.length < oldValue.text.length) {
        if (oldValue.text.endsWith(suffix)) {
          return TextEditingValue(
            text: oldValue.text.substring(0, oldValue.text.length - 1),
            selection: TextSelection.collapsed(offset: oldValue.text.length - 1),
          );
        } else {
          return newValue;
        }
      }
    }

    final newText = newValue.text.replaceAll(RegExp(r'[^\d.,]'), '');

    final formattedText = newText.replaceAll(RegExp('^0+(?=.)'), '').replaceAll(RegExp(r'\.+'), '.');

    if (formattedText.isNotEmpty) {
      return TextEditingValue(
        text: '$formattedText$suffix',
        selection: TextSelection.collapsed(offset: formattedText.length + suffix.length),
      );
    } else {
      return TextEditingValue.empty;
    }
  }
}

class TimeTextFormatter extends TextInputFormatter {
  const TimeTextFormatter();

  static String fromSeconds(int seconds) {
    final hasHours = seconds >= 3600;

    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');

    return '${hasHours ? '$hours:' : ''}$minutes:$remainingSeconds';
  }

  static int toSecondsInt(String _value) {
    String value = _value;

    if (value.length == 5) {
      value = '00:$value';
    }

    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$');

    final match = regex.allMatches(value);

    if (match.isEmpty) {
      return int.tryParse(value) ?? 0;
    }

    final hours = int.tryParse(match.elementAt(0).group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.elementAt(0).group(2) ?? '') ?? 0;
    final seconds = int.tryParse(match.elementAt(0).group(3) ?? '') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Format the input as hh:mm:ss
    final String formattedValue = formatTime(newValue.text);

    // Return the updated value with caret at the end
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  // Function to format time as hh:mm:ss
  String formatTime(String value) {
    // Remove non-digit characters
    String cleanedValue = value.replaceAll(RegExp('[^0-9]'), '');

    //remove leading zeros
    cleanedValue = cleanedValue.replaceFirst(RegExp('^0+'), '');

    final hasHours = cleanedValue.length > 4;

    const maxLengthWithHours = 6;
    const maxLengthWithMinutes = 4;

    // Pad with leading zeros if needed
    if (!hasHours) {
      while (cleanedValue.length < maxLengthWithMinutes) {
        cleanedValue = '0$cleanedValue';
      }
    } else {
      while (cleanedValue.length < maxLengthWithHours) {
        cleanedValue = '0$cleanedValue';
      }
    }

    // Ensure the length is not more than maxLength characters
    if (hasHours) {
      if (cleanedValue.length > maxLengthWithHours) {
        cleanedValue = cleanedValue.replaceFirst(RegExp('^0+'), '');
        cleanedValue = cleanedValue.padLeft(maxLengthWithHours, '0');
      }
    } else {
      if (cleanedValue.length > maxLengthWithMinutes) {
        cleanedValue = cleanedValue.replaceFirst(RegExp('^0+'), '');
        cleanedValue = cleanedValue.padLeft(maxLengthWithMinutes, '0');
      }
    }

    // Insert colons between hours, minutes, and seconds
    return '${cleanedValue.substring(0, 2)}:${cleanedValue.substring(2, 4)}${hasHours ? ':${cleanedValue.substring(4, 6)}' : ''}';
  }
}
