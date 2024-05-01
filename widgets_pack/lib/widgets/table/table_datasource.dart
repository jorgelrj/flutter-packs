import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets/table/table.dart';
import 'package:widgets_pack/widgets/widgets.dart';

enum TableActionsType { none, single, multi }

class TableDatasourceConfig<M extends Object> extends Equatable {
  final int pageSize;
  final int currentPage;
  final Map<int, List<M>> pages;
  final bool firstSearch;
  final bool loadedAll;
  final bool loading;

  const TableDatasourceConfig({
    this.pageSize = 10,
    this.currentPage = 0,
    this.pages = const {},
    this.firstSearch = true,
    this.loadedAll = false,
    this.loading = false,
  });

  @override
  List<Object?> get props => [pageSize, currentPage, pages, firstSearch, loadedAll, loading];

  int get currentPageLength => pages[currentPage]?.length ?? 0;

  bool get loadedAllItemsForCurrentPage => pages[currentPage]?.length == pageSize;

  int get lastAvailablePage {
    if (loadedAll) {
      return pages.length - 1;
    }

    return pages.length;
  }

  bool get showEmptyState {
    return !loading && !firstSearch && currentPage == 0 && pages[currentPage]?.isEmpty == true;
  }

  bool get canGoToPreviousPage => currentPage > 0 && !loading;

  bool get canGoToNextPage => !loading && (currentPage < lastAvailablePage || !loadedAll);

  TableDatasourceConfig<M> copyWith({
    int? pageSize,
    int? currentPage,
    Map<int, List<M>>? pages,
    bool? firstSearch,
    bool? loadedAll,
    bool? loading,
  }) {
    return TableDatasourceConfig(
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      pages: pages ?? this.pages,
      firstSearch: firstSearch ?? this.firstSearch,
      loadedAll: loadedAll ?? this.loadedAll,
      loading: loading ?? this.loading,
    );
  }
}

class TableDataSource<M extends Object> extends ChangeNotifier {
  final TableLoader<M> loader;
  List<TableColumn<M>> columns;

  TableDataSource({
    required this.loader,
    required this.columns,
    required TableActionsType actions,
    required int pageSize,
  }) {
    config = TableDatasourceConfig<M>(pageSize: pageSize);
    setActionsType(actions);
    _load();
  }

  late TableDatasourceConfig<M> config;

  TableActionsType actionsType = TableActionsType.none;

  int get currentPage => config.currentPage;

  int get pageSize => config.pageSize;

  (M?, bool selected) currentItemAt(int index) {
    final pageItems = config.pages[config.currentPage] ?? [];

    final item = pageItems.elementAtOrNull(index);

    return (
      item,
      selectedItems.contains(item),
    );
  }

  List<M> selectedItems = [];

  void setActionsType(TableActionsType actionsType) {
    this.actionsType = actionsType;
  }

  void setLoading(bool loading) {
    config = config.copyWith(loading: loading);
    notifyListeners();
  }

  void setPage(int page) {
    if (page < 0) {
      return;
    }

    if (config.loading) {
      return;
    }

    config = config.copyWith(currentPage: page);
    notifyListeners();

    _load();
  }

  void addOrRemoveItem(M item) {
    if (actionsType == TableActionsType.none) {
      return;
    }

    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      if (actionsType == TableActionsType.single) {
        selectedItems = [item];
      } else {
        selectedItems.add(item);
      }
    }

    notifyListeners();
  }

  void clearSelection() {
    selectedItems.clear();
    notifyListeners();
  }

  void setColumns(List<TableColumn<M>> columns) {
    this.columns = columns;
    notifyListeners();
  }

  void replaceItem(ItemPosition position, M item) {
    final pageItems = config.pages[position.$1] ?? [];

    final index = position.$2;

    if (index >= pageItems.length) {
      return;
    }

    pageItems[index] = item;

    config = config.copyWith(
      pages: {
        ...config.pages,
        position.$1: pageItems,
      },
    );
  }

  Future<void> reset({bool keepOffset = false}) {
    if (keepOffset) {
      config = TableDatasourceConfig<M>(
        firstSearch: false,
        currentPage: config.currentPage,
        pageSize: config.pageSize,
      );
    } else {
      config = TableDatasourceConfig<M>(
        pageSize: config.pageSize,
      );
    }

    selectedItems.clear();

    notifyListeners();

    return _load();
  }

  Future<void> _load() async {
    if (config.loadedAll || config.loadedAllItemsForCurrentPage) {
      return;
    }

    setLoading(true);

    final items = switch (loader) {
      (TableStaticLoader<M>()) => await (loader as TableStaticLoader<M>).items(),
      (TablePaginatedLoader<M>()) => await (loader as TablePaginatedLoader<M>).paginate(
          config.currentPage,
          config.pageSize,
        ),
    };

    if (items.isEmpty && !config.firstSearch) {
      config = config.copyWith(
        loadedAll: true,
        currentPage: config.currentPage - 1,
      );
      setLoading(false);

      return;
    }

    config = config.copyWith(
      pages: {
        ...config.pages,
        if (items.length <= config.pageSize)
          config.currentPage: items
        else
          ...items.chunked(config.pageSize).mapIndexed((index, chunk) {
            return {
              config.currentPage + index: chunk,
            };
          }).reduce((value, element) => value..addAll(element)),
      },
      loadedAll: loader is TableStaticLoader<M> || items.length < config.pageSize,
      firstSearch: false,
    );

    setLoading(false);
  }
}
