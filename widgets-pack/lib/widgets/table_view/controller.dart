import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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

  String? _currentOperationId;

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

  bool get allItemsSelected {
    return _selectedItems.isNotEmpty && currentPageItems.length == _selectedItems.length;
  }

  void toggleItem(M item) {
    final index = _items.indexOf(item);

    if (index == -1) {
      return;
    }

    handleItemTapAtIndex(index);
  }

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

    return currentPageItems[index];
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

  bool itemAtIndexIsSelected(int _index, {bool adjustForPage = false}) {
    final index = adjustForPage ? _index + _currentPage * _pageSize : _index;

    if (index < 0 || index >= currentPageItems.length) {
      return false;
    }

    return _selectedItems.contains(currentPageItems[index]);
  }

  @mustCallSuper
  Future<void> reload({bool keepOffset = false, bool keepSelection = false}) async {
    if (!keepOffset) {
      _currentPage = 0;
      _items = [];
      _maxItems = null;
    }

    if (!keepSelection) {
      _selectedItems = [];
    }
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

    if (currentPageItems.isEmpty) {
      return reload(keepOffset: true, keepSelection: true);
    } else {
      notifyListeners();
    }
  }

  Future<void> previousPage() async {
    if (_currentPage == 0) {
      return;
    }

    _currentPage--;

    if (currentPageItems.isEmpty) {
      return reload(keepOffset: true, keepSelection: true);
    } else {
      notifyListeners();
    }
  }
}

class AppTableViewListController<M extends Object> extends AppTableViewController<M> {
  final FutureOr<List<M>> Function() fetcher;

  AppTableViewListController({
    required this.fetcher,
  });

  @override
  Future<void> reload({bool keepOffset = false, bool keepSelection = false}) async {
    final opId = const Uuid().v4();
    _currentOperationId = opId;

    super.reload(keepOffset: keepOffset);

    loading = true;

    _items = await fetcher();

    if (_currentOperationId != opId) {
      return;
    }

    _maxItems = _items.length;

    loading = false;
  }
}

class AppTableViewPaginatedController<M extends Object> extends AppTableViewController<M> {
  final FutureOr<(List<M> items, int? maxItems)> Function(int page, int pageSize) fetcher;

  AppTableViewPaginatedController({
    required this.fetcher,
  });

  @override
  Future<void> reload({bool keepOffset = false, bool keepSelection = false}) async {
    final opId = const Uuid().v4();

    _currentOperationId = opId;

    super.reload(keepOffset: keepOffset);

    loading = true;

    final (list, count) = await fetcher(
      currentPage,
      pageSize,
    );

    if (_currentOperationId != opId) {
      return;
    }

    _maxItems = count;
    if (keepOffset && currentPageItems.isNotEmpty) {
      final startOffset = _currentPage * _pageSize;

      final updatedList = List.of(items)
        ..removeRange(startOffset, startOffset + currentPageItems.length)
        ..insertAll(startOffset, list);

      _items = updatedList;
    } else {
      _items = [...items, ...list];
    }

    loading = false;
  }
}
