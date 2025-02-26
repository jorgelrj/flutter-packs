import 'package:flutter/cupertino.dart';

class NumberValidator {
  const NumberValidator._();

  static FormFieldValidator<num> isBetween(num min, num max, {String? message}) {
    return (value) {
      if (value == null) {
        return null;
      }

      if (value < min || value > max) {
        return message ?? 'Value must be between $min and $max';
      }

      return null;
    };
  }

  static FormFieldValidator<num> isGreaterThan(num greaterThan, {String? message}) {
    return (num? value) {
      if (value == null) {
        return null;
      }

      if (value <= greaterThan) {
        return message ?? 'Value must be greater than $greaterThan';
      }

      return null;
    };
  }

  static FormFieldValidator<num> isLessThan(num lessThan, {String? message}) {
    return (num? value) {
      if (value == null) {
        return null;
      }

      if (value >= lessThan) {
        return message ?? 'Value must be less than $lessThan';
      }

      return null;
    };
  }

  static FormFieldValidator<num> notNull([String? message]) {
    return (value) {
      if (value == null) {
        return message ?? 'Value must not be null';
      }

      return null;
    };
  }

  static FormFieldValidator<num> chain(List<FormFieldValidator<num>> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }

      return null;
    };
  }
}
