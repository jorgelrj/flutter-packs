import 'dart:async';

import 'package:extensions_pack/extensions_pack.dart';

sealed class AppItemsHandler<T> {
  final bool Function(T, T)? compareItems;
  final String Function(T)? itemAsString;

  const AppItemsHandler({
    this.compareItems,
    this.itemAsString,
  });

  FutureOr<void> onListChanged(List<T> list);

  bool compare(T a, T b) => compareItems?.call(a, b) ?? a == b;

  String asString(T item) => itemAsString?.call(item) ?? item.toString();
}

class AppSingleItemHandler<T> extends AppItemsHandler<T> {
  final FutureOr<void> Function(T?) onChanged;
  final T? initialValue;

  const AppSingleItemHandler(
    this.onChanged, {
    this.initialValue,
    super.compareItems,
    super.itemAsString,
  });

  @override
  FutureOr<void> onListChanged(List<T> list) => onChanged(list.firstOrNull);
}

class AppMultipleItemsHandler<T> extends AppItemsHandler<T> {
  final FutureOr<void> Function(List<T>) onChanged;
  final List<T> initialValue;

  const AppMultipleItemsHandler(
    this.onChanged, {
    this.initialValue = const [],
    super.compareItems,
    super.itemAsString,
  });

  @override
  FutureOr<void> onListChanged(List<T> list) => onChanged(list);
}
