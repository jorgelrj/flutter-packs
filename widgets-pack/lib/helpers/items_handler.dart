import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';

sealed class AppItemsHandler<T> extends Equatable {
  final bool Function(T, T)? compareItems;
  final bool Function(T, String)? filterItems;
  final String Function(T)? itemAsString;

  const AppItemsHandler({
    this.compareItems,
    this.itemAsString,
    this.filterItems,
  });

  FutureOr<void> onListChanged(List<T> list);

  bool compare(T a, T b) => compareItems?.call(a, b) ?? a == b;

  String asString(T item) => itemAsString?.call(item) ?? item.toString();

  bool filter(T item, String filter) {
    return filterItems?.call(item, filter) ?? asString(item).toLowerCase().contains(filter.toLowerCase());
  }
}

class AppSingleItemHandler<T> extends AppItemsHandler<T> {
  final FutureOr<void> Function(T?) onChanged;
  final T? initialValue;

  const AppSingleItemHandler(
    this.onChanged, {
    this.initialValue,
    super.compareItems,
    super.itemAsString,
    super.filterItems,
  });

  @override
  FutureOr<void> onListChanged(List<T> list) => onChanged(list.firstOrNull);

  @override
  List<Object?> get props => [initialValue];
}

class AppMultipleItemsHandler<T> extends AppItemsHandler<T> {
  final FutureOr<void> Function(List<T>) onChanged;
  final List<T> initialValue;
  final ListTileControlAffinity controlAffinity;

  const AppMultipleItemsHandler(
    this.onChanged, {
    this.initialValue = const [],
    this.controlAffinity = ListTileControlAffinity.leading,
    super.compareItems,
    super.itemAsString,
    super.filterItems,
  });

  @override
  FutureOr<void> onListChanged(List<T> list) => onChanged(list);

  @override
  List<Object?> get props => [initialValue];
}
