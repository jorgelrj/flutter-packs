import 'package:flutter/material.dart';

class ListValidator {
  static FormFieldValidator<List> chain(List<FormFieldValidator<List>> validators) {
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

  static FormFieldValidator<List> notEmpty([String? message]) {
    return (List? value) {
      if (value == null || value.isEmpty) {
        return message ?? 'This field is required';
      }

      return null;
    };
  }

  static FormFieldValidator<List> anyIsValid(List<FormFieldValidator<List>> validators) {
    return (List? value) {
      bool isValid = false;
      String? error;
      for (final validator in validators) {
        error = validator(value);
        if (error == null) {
          isValid = true;
          break;
        }
      }

      return isValid ? null : error;
    };
  }

  static FormFieldValidator<List> maxLength(int length, [String? message]) {
    return (List? value) {
      if (value != null && value.length > length) {
        return message ?? 'This field must have at most $length items';
      }

      return null;
    };
  }
}
