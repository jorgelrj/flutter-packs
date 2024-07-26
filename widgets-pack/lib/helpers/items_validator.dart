import 'package:flutter/cupertino.dart';

sealed class AppItemsValidator<T> {
  const AppItemsValidator();

  String? validate(List<T> value);
}

class AppSingleItemValidator<T> extends AppItemsValidator<T> {
  final FormFieldValidator<T> validator;

  const AppSingleItemValidator(
    this.validator,
  );

  @override
  String? validate(List<T> value) {
    return validator(value.firstOrNull);
  }
}

class AppMultipleItemsValidator<T> extends AppItemsValidator<T> {
  final FormFieldValidator<List<T>> validator;

  const AppMultipleItemsValidator(
    this.validator,
  );

  @override
  String? validate(List<T> value) {
    return validator(value);
  }
}
