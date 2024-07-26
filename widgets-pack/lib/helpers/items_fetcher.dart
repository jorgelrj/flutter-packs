import 'dart:math' as math;

import 'package:equatable/equatable.dart';

sealed class AppItemsFetcher<T> extends Equatable {
  const AppItemsFetcher();
}

class AppLocalItemsFetcher<T> extends AppItemsFetcher<T> {
  final List<T> items;

  const AppLocalItemsFetcher(
    this.items,
  );

  @override
  List<Object?> get props => [items];
}

abstract class AppRemoteItemsFetcher<T> extends AppItemsFetcher<T> {
  const AppRemoteItemsFetcher();
}

class AppRemoteListItemsFetcher<T> extends AppRemoteItemsFetcher<T> {
  final Future<List<T>> Function() getItems;

  const AppRemoteListItemsFetcher(
    this.getItems,
  );

  @override
  List<Object?> get props => [getItems];
}

class AppRemoteSearchListItemsFetcher<T> extends AppRemoteItemsFetcher<T> {
  final Future<List<T>> Function(String search) getItems;

  final String _valueKey;

  AppRemoteSearchListItemsFetcher(
    this.getItems, {
    String? valueKey,
  }) : _valueKey = valueKey ?? math.Random().nextDouble().toString();

  @override
  List<Object?> get props => [_valueKey];
}
