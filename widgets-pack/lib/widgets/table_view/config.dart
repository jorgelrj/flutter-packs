import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppTableViewConfig<M extends Object> extends Equatable {
  final List<Widget> filters;
  final AppButtonConfig? action;
  final List<AppAction<M>> Function(List<M>)? actions;
  final TableActionsType actionType;
  final bool showActionsAsTrailingIcon;
  final ValueChanged<M>? onDoubleTapRow;
  final WidgetBuilder? emptyStateBuilder;
  final int pageSize;
  final int fixedColumns;
  final List<AppAction<M>> Function(M)? persistentTrailingActions;
  final Set<int> pageSizes;

  const AppTableViewConfig({
    TableActionsType? actionType,
    this.filters = const [],
    this.actions,
    this.action,
    this.showActionsAsTrailingIcon = false,
    this.onDoubleTapRow,
    this.emptyStateBuilder,
    this.pageSize = 10,
    this.fixedColumns = 0,
    this.persistentTrailingActions,
    this.pageSizes = const {10},
  }) : actionType = actionType ?? (actions == null ? TableActionsType.none : TableActionsType.multi);

  @override
  List<Object?> get props => [
        filters,
        action,
        actionType,
        showActionsAsTrailingIcon,
        pageSize,
        fixedColumns,
        persistentTrailingActions,
        pageSizes,
      ];
}
