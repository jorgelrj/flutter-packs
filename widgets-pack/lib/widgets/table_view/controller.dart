import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets/widgets.dart';

abstract class AppTableViewController<M extends Object> extends ChangeNotifier {
  AppTableViewController() {
    reload();
  }

  TableActionsType _actionsType = TableActionsType.none;
  TableActionsType get actionsType => _actionsType;
  set actionsType(TableActionsType actionsType) {
    _selectedItems = [];
    _actionsType = actionsType;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  int _pageSize = 10;
  int get pageSize => _pageSize;
  set pageSize(int pageSize) {
    _pageSize = pageSize;
    _currentPage = 0;
    notifyListeners();
  }

  int _currentPage = 0;
  int get currentPage => _currentPage;
  set currentPage(int currentPage) {
    _currentPage = currentPage;
    notifyListeners();
  }

  int? _maxItems;
  int? get maxItems => _maxItems;
  set maxItems(int? maxItems) {
    _maxItems = maxItems;

    notifyListeners();
  }

  List<M> _items = [];
  List<M> get items => _items;
  set items(List<M> items) {
    _items = items;
    notifyListeners();
  }

  List<M> get currentPageItems {
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;

    return _items.sublist(
      start,
      end.clamp(0, items.length),
    );
  }

  List<M> _selectedItems = [];
  List<M> get selectedItems => _selectedItems;
  set selectedItems(List<M> selectedItems) {
    _selectedItems = selectedItems;
    notifyListeners();
  }

  bool get isMaxItemsReached {
    return _maxItems != null && _items.length >= _maxItems!;
  }

  bool get isMaxItemsKnown => _maxItems != null;

  bool get allItemsSelected => currentPageItems.length == _selectedItems.length;

  void handleItemTapAtIndex(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    switch (actionsType) {
      case TableActionsType.single:
        final item = currentPageItems[index];

        if (selectedItems.contains(item)) {
          selectedItems = [];
        } else {
          selectedItems = [item];
        }

      case TableActionsType.multi:
        final item = currentPageItems[index];

        if (selectedItems.contains(item)) {
          selectedItems = selectedItems.where((element) => element != item).toList();
        } else {
          selectedItems = [...selectedItems, item];
        }

      case _:
        return;
    }
  }

  M? itemAtIndex(int index) {
    if (index < 0 || index >= currentPageItems.length) {
      return null;
    }

    return _items[index];
  }

  void handleSelectAll() {
    if (allItemsSelected) {
      selectedItems = [];
    } else {
      selectedItems = [...currentPageItems];
    }
  }

  void clearSelection() {
    selectedItems = [];
  }

  bool itemAtIndexIsSelected(int index) {
    if (index < 0 || index >= currentPageItems.length) {
      return false;
    }

    return _selectedItems.contains(currentPageItems[index]);
  }

  @mustCallSuper
  Future<void> reload({bool keepOffset = false}) async {
    _selectedItems = [];
  }

  Future<void> nextPage() async {
    late bool isLastPage;

    if (isMaxItemsKnown) {
      isLastPage = (_maxItems! / _pageSize).ceil() == _currentPage + 1;
    } else {
      isLastPage = currentPageItems.length < _pageSize;
    }

    if (isLastPage) {
      return;
    }

    _currentPage++;
    selectedItems = [];

    if (currentPageItems.isEmpty) {
      return reload();
    }
  }

  Future<void> previousPage() async {
    if (_currentPage == 0) {
      return;
    }

    _currentPage--;
    selectedItems = [];

    if (currentPageItems.isEmpty) {
      return reload();
    }
  }
}

class AppTableViewListController<M extends Object> extends AppTableViewController<M> {
  final FutureOr<List<M>> _list;

  AppTableViewListController({
    required FutureOr<List<M>> items,
  }) : _list = items;

  @override
  Future<void> reload({bool keepOffset = false}) async {
    super.reload(keepOffset: keepOffset);

    loading = true;

    _items = await _list;
    _maxItems = _items.length;

    if (!keepOffset) {
      _currentPage = 0;
    }

    loading = false;
  }
}

class AppTableViewPaginatedController<M extends Object> extends AppTableViewController<M> {
  final FutureOr<(List<M> items, int? maxItems)> Function(int page, int pageSize) fetcher;

  AppTableViewPaginatedController({
    required this.fetcher,
  });

  @override
  Future<void> reload({bool keepOffset = false}) async {
    super.reload(keepOffset: keepOffset);

    loading = true;

    final data = await fetcher(
      currentPage,
      pageSize,
    );

    _items = [...items, ...data.$1];
    _maxItems = data.$2;

    loading = false;
  }
}
