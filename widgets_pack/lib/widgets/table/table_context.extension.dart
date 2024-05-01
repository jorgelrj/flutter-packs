part of 'table_widget.dart';

extension _TableContextExtension on BuildContext {
  _AppTableState<M> tableState<M extends Object>() {
    return AppTable.of<M>(this);
  }

  TableDataSource<M> tableDataSource<M extends Object>() {
    return tableState<M>()._dataSource;
  }

  TableController<M>? maybeController<M extends Object>() {
    return AppTable.maybeOf<M>(this)?.widget.controller;
  }
}
