part of 'table_widget.dart';

typedef TableLoadFn<M> = Future<List<M>> Function(int page, int pageSize);
typedef ItemPosition = (int page, int row);

sealed class TableLoader<M> extends Equatable {
  const TableLoader();
}

final class TableStaticLoader<M> extends TableLoader<M> {
  final FutureOr<List<M>> Function() items;

  const TableStaticLoader(this.items);

  @override
  List<Object?> get props => [items];
}

final class TablePaginatedLoader<M> extends TableLoader<M> {
  final TableLoadFn<M> paginate;

  const TablePaginatedLoader(this.paginate);

  @override
  List<Object?> get props => [paginate];
}

class TableController<M extends Object> {
  final TableLoader<M> loader;

  TableController({
    required this.loader,
  });

  late TableDataSource<M> dataSource;

  Future<void> reload({
    bool keepOffset = false,
  }) async {
    return dataSource.reset(
      keepOffset: keepOffset,
    );
  }

  List<M> get allItems {
    return dataSource.config.pages.values.expand((element) => element).toList();
  }

  void replaceItemAt(
    ItemPosition position,
    M item,
  ) {
    return dataSource.replaceItem(
      position,
      item,
    );
  }

  void addOrRemove(M item) => dataSource.addOrRemoveItem(item);
}
