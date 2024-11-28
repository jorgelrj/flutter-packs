import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppTableViewConfig<M extends Object> extends Equatable {
  final List<Widget> filters;
  final List<AppAction<M>> Function(List<M>)? actions;
  final TableActionsType actionType;
  final bool showActionsAsTrailingIcon;
  final ValueChanged<M>? onDoubleTapRow;
  final WidgetBuilder? emptyStateBuilder;
  final int pageSize;
  final int fixedColumns;
  final List<AppAction<M>> Function(M)? persistentTrailingActions;
  final Set<int> pageSizes;
  final String Function(int)? itemsSelectedString;
  final ValueChanged<List<M>>? onItemsSelected;
  final bool showPagination;

  const AppTableViewConfig({
    TableActionsType? actionType,
    this.filters = const [],
    this.actions,
    this.showActionsAsTrailingIcon = false,
    this.onDoubleTapRow,
    this.emptyStateBuilder,
    this.pageSize = 10,
    this.fixedColumns = 0,
    this.persistentTrailingActions,
    this.pageSizes = const {10},
    this.itemsSelectedString,
    this.onItemsSelected,
    this.showPagination = true,
  }) : actionType = actionType ?? (actions == null ? TableActionsType.none : TableActionsType.multi);

  @override
  List<Object?> get props => [
        filters,
        actionType,
        showActionsAsTrailingIcon,
        pageSize,
        fixedColumns,
        persistentTrailingActions,
        pageSizes,
        itemsSelectedString,
        onItemsSelected,
        showPagination,
      ];
}
