import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:widgets_pack/helpers/helpers.dart';
import 'package:widgets_pack/widgets/widgets.dart';

part 'filters/boolean.filter.dart';
part 'filters/date.filter.dart';
part 'filters/list.filter.dart';
part 'filters/search.filter.dart';
part 'filters/text.filter.dart';
part 'table_config_consumer.dart';
part 'table_context.extension.dart';
part 'table_controller.dart';
part 'table_filter.dart';

typedef TableActionFn<M extends Object> = List<AppAction<M>> Function(List<M> items);

class AppTable<M extends Object> extends StatefulWidget {
  final TableController<M> controller;
  final TableActionFn<M>? actions;

  /// if null, defaults to [TableActionsType.none] if [actions] null
  /// or [TableActionsType.single] if [actions] is not null
  final TableActionsType? actionsType;

  final List<TableColumn<M>> columns;
  final List<Widget> filters;
  final void Function(M)? onRowTap;
  final void Function(M)? onRowDoubleTap;
  final AppButtonConfig? headerAction;
  final WidgetBuilder? emptyStateBuilder;
  final WidgetBuilder? aboveTableBuilder;
  final Widget? Function(BuildContext context, List<Widget> filters)? filterBuilder;
  final EdgeInsets headerPadding;
  final int pageSize;
  final bool showPagination;
  final String? headerTitle;
  final bool renderEmptyRows;
  final ValueChanged<List<M>>? onSelectedItemsChanged;
  final String Function(int)? itemsSelectedTextBuilder;

  const AppTable({
    required this.controller,
    required this.columns,
    this.actions,
    this.actionsType,
    this.filters = const [],
    this.onRowTap,
    this.onRowDoubleTap,
    this.headerAction,
    this.emptyStateBuilder,
    this.aboveTableBuilder,
    this.headerPadding = EdgeInsets.zero,
    this.filterBuilder,
    this.pageSize = 10,
    this.showPagination = true,
    this.headerTitle,
    this.renderEmptyRows = true,
    this.onSelectedItemsChanged,
    this.itemsSelectedTextBuilder,
    super.key,
  });

  @override
  State<AppTable<M>> createState() => _AppTableState<M>();

  static _AppTableState<M> of<M extends Object>(BuildContext context) {
    return context.findAncestorStateOfType<_AppTableState<M>>()!;
  }

  static _AppTableState<M>? maybeOf<M extends Object>(BuildContext context) {
    return context.findAncestorStateOfType<_AppTableState<M>>();
  }
}

class _AppTableState<M extends Object> extends State<AppTable<M>> {
  late TableDataSource<M> _dataSource;

  WPTableStringsConfig get _strings => context.wpStringsConfig.table;

  TableActionsType get actionsType {
    if (widget.actionsType != null) {
      return widget.actionsType!;
    }

    if (widget.actions == null) {
      return TableActionsType.none;
    } else {
      return TableActionsType.single;
    }
  }

  @override
  void initState() {
    super.initState();

    _dataSource = TableDataSource<M>(
      loader: widget.controller.loader,
      columns: widget.columns,
      actions: actionsType,
      pageSize: widget.pageSize,
    );

    widget.controller.dataSource = _dataSource;

    _dataSource.addListener(() {
      widget.onSelectedItemsChanged?.call(_dataSource.selectedItems);
    });

    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void didUpdateWidget(covariant AppTable<M> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.columns != widget.columns) {
      _dataSource.setColumns(widget.columns);
    }

    if (oldWidget.actions != widget.actions || oldWidget.actionsType != widget.actionsType) {
      _dataSource.actionsType = actionsType;
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }

    _dataSource.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _DatasourceConfigConsumer<M, List<TableColumn<M>>>(
          selector: (source) => source.columns,
          builder: (context, columns, child) {
            final fixedLeftColumns = columns.where((c) => c.fixedPosition == ColumnFixedPosition.left).toList();
            final fixedRightColumns = columns.where((c) => c.fixedPosition == ColumnFixedPosition.right).toList();
            final normalColumns = columns.where((c) => !c.fixed).toList();
            final fixedLeftColumnsWidth = fixedLeftColumns.fold<double>(
              0,
              (previousValue, element) => previousValue + element.width,
            );
            final fixedRightColumnsWidth = fixedRightColumns.fold<double>(
              0,
              (previousValue, element) => previousValue + element.width,
            );

            final header = Padding(
              padding: widget.headerPadding,
              child: _DatasourceConfigConsumer<M, (List<M>, int)>(
                selector: (source) => (source.selectedItems, source.selectedItems.length),
                builder: (context, state, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.headerTitle != null && widget.filters.isNotEmpty)
                              Text(
                                widget.headerTitle!,
                                style: context.textTheme.headlineSmall,
                              ).padded(const EdgeInsets.symmetric(horizontal: kXSSize, vertical: kGridSpacer)),
                            if (state.$2 == 0)
                              widget.filterBuilder?.call(context, widget.filters) ??
                                  _AppTableFilterRow(
                                    headerTitle: widget.headerTitle,
                                    headerAction: widget.headerAction,
                                    filters: widget.filters,
                                  )
                            else
                              AppTableActionsRow(
                                key: ValueKey(state.$1),
                                items: state.$1,
                                onClearAll: _dataSource.clearSelection,
                                actions: widget.actions,
                                itemsSelectedTextBuilder: widget.itemsSelectedTextBuilder,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );

            final table = _DatasourceConfigConsumer<M, bool>(
              selector: (source) => source.config.showEmptyState,
              builder: (context, showEmptyState, child) {
                if (showEmptyState) {
                  return widget.emptyStateBuilder?.call(context) ??
                      SizedBox(
                        height: 12 * 52,
                        child: Center(
                          child: Text(_strings.noItemsFound),
                        ),
                      );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.aboveTableBuilder != null) widget.aboveTableBuilder!(context),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fixedLeftColumns.isNotEmpty)
                            SizedBox(
                              width: fixedLeftColumnsWidth,
                              child: _Table<M>(
                                key: const Key('fixed_columns_table'),
                                columns: fixedLeftColumns,
                                actions: widget.actions,
                                dataSource: _dataSource,
                                rowBorder: Border(
                                  right: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                showLoader: false,
                                onRowTap: widget.onRowTap,
                                onRowDoubleTap: widget.onRowDoubleTap,
                                renderEmptyRows: widget.renderEmptyRows,
                                maxRowHeight: 56,
                              ),
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: normalColumns
                                    .fold<double>(56, (previousValue, element) => previousValue + element.width)
                                    .clamp(
                                      constraints.minWidth - fixedLeftColumnsWidth - fixedRightColumnsWidth,
                                      double.maxFinite,
                                    ),
                                child: _Table<M>(
                                  actions: widget.actions,
                                  key: const Key('normal_columns_table'),
                                  columns: normalColumns,
                                  dataSource: _dataSource,
                                  onRowTap: widget.onRowTap,
                                  onRowDoubleTap: widget.onRowDoubleTap,
                                  renderEmptyRows: widget.renderEmptyRows,
                                  maxRowHeight: fixedLeftColumns.isNotEmpty ? 56 : null,
                                ),
                              ),
                            ),
                          ),
                          if (fixedRightColumns.isNotEmpty)
                            SizedBox(
                              width: fixedRightColumnsWidth,
                              child: _Table<M>(
                                key: const Key('fixed_right_columns_table'),
                                columns: fixedRightColumns,
                                actions: widget.actions,
                                dataSource: _dataSource,
                                rowBorder: Border(
                                  left: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                showLoader: false,
                                onRowTap: widget.onRowTap,
                                onRowDoubleTap: widget.onRowDoubleTap,
                                renderEmptyRows: widget.renderEmptyRows,
                                maxRowHeight: 56,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.showPagination)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        constraints: const BoxConstraints(minHeight: 52),
                        child: _DatasourceConfigConsumer<M, TableDatasourceConfig<M>>(
                          selector: (source) => source.config,
                          builder: (context, config, child) {
                            final firstIndex = config.currentPage * config.pageSize + 1;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '$firstIndex - ${firstIndex + (config.pages[config.currentPage]?.length ?? 1) - 1}',
                                ),
                                const Spacing(mainAxisExtent: kXSSize),
                                IconButton(
                                  onPressed: config.canGoToPreviousPage
                                      ? () {
                                          _dataSource.setPage(0);
                                        }
                                      : null,
                                  icon: const Icon(Icons.skip_previous),
                                ),
                                IconButton(
                                  onPressed: config.canGoToPreviousPage
                                      ? () {
                                          _dataSource.setPage(config.currentPage - 1);
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                IconButton(
                                  onPressed: config.canGoToNextPage
                                      ? () {
                                          _dataSource.setPage(config.currentPage + 1);
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                                IconButton(
                                  onPressed: config.canGoToNextPage
                                      ? () {
                                          _dataSource.setPage(config.lastAvailablePage);
                                        }
                                      : null,
                                  icon: const Icon(Icons.skip_next),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            );

            return StickyHeader(
              header: header,
              content: table,
            );
          },
        );
      },
    );
  }
}

class _Table<M extends Object> extends StatefulWidget {
  final List<TableColumn<M>> columns;
  final TableDataSource<M> dataSource;
  final bool showLoader;
  final Border rowBorder;
  final TableActionFn<M>? actions;
  final void Function(M)? onRowTap;
  final void Function(M)? onRowDoubleTap;
  final bool renderEmptyRows;
  final double? maxRowHeight;

  const _Table({
    required this.columns,
    required this.dataSource,
    required this.actions,
    this.showLoader = true,
    this.rowBorder = const Border(),
    this.onRowTap,
    this.onRowDoubleTap,
    this.renderEmptyRows = true,
    this.maxRowHeight,
    super.key,
  });

  @override
  State<_Table<M>> createState() => _TableState<M>();
}

class _TableState<M extends Object> extends State<_Table<M>> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DatasourceConfigConsumer<M, bool>(
      selector: (source) => source.config.loading,
      builder: (context, loading, child) {
        return Skeletonizer(
          enabled: widget.showLoader && loading,
          child: child!,
        );
      },
      child: _DatasourceConfigConsumer<M, int>(
        selector: (source) {
          return widget.renderEmptyRows ? source.config.pageSize : source.config.currentPageLength;
        },
        builder: (context, pageSize, child) {
          return ListView.separated(
            itemCount: pageSize + 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(height: 0, color: Theme.of(context).dividerColor),
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final itemIndex = index - 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFirst)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: _DatasourceConfigConsumer<M, bool>(
                            selector: (source) => source.selectedItems.length == source.config.pageSize,
                            listener: (source) {
                              if (source.actionsType.isMulti) {
                                if (source.selectedItems.isEmpty) {
                                  _controller.reverse();
                                } else {
                                  _controller.forward();
                                }
                              }
                            },
                            builder: (context, allSelected, child) {
                              return Row(
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 56),
                                    child: SizeTransition(
                                      sizeFactor: _controller,
                                      axis: Axis.horizontal,
                                      child: Center(
                                        child: Checkbox(
                                          value: allSelected,
                                          onChanged: (_) => widget.dataSource.toggleAllItems(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (final column in widget.columns) column.labelBuilder(context),
                                ],
                              );
                            },
                          ),
                        ),
                        const Divider(thickness: 0, height: 0),
                      ],
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: widget.maxRowHeight ?? 56),
                      child: SizedBox(
                        height: widget.maxRowHeight,
                        child: _DatasourceConfigConsumer<M, (M?, bool)>(
                          selector: (source) => source.currentItemAt(itemIndex),
                          builder: (context, model, child) {
                            if (model.$1 == null) {
                              return _DatasourceConfigConsumer<M, bool>(
                                selector: (source) => source.config.loading,
                                builder: (context, loading, child) {
                                  if (widget.showLoader && loading) {
                                    return Row(
                                      children: [
                                        ...List.generate(widget.columns.length, (index) {
                                          return SizedBox(
                                            width: widget.columns[index].width,
                                            child: Text(BoneMock.title),
                                          );
                                        }),
                                      ],
                                    );
                                  }

                                  return const SizedBox();
                                },
                              );
                            }

                            return KeyedSubtree(
                              key: ValueKey(model.$1),
                              child: _TableRow<M>(
                                key: ValueKey((index, model)),
                                item: model.$1!,
                                rowIndex: itemIndex,
                                actions: widget.actions,
                                selected: model.$2,
                                columns: widget.columns,
                                rowBorder: widget.rowBorder,
                                onRowDoubleTap: widget.onRowDoubleTap,
                                onRowTap: widget.onRowTap,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TableRow<M extends Object> extends StatefulWidget {
  final M item;
  final int rowIndex;
  final bool selected;
  final List<TableColumn<M>> columns;
  final void Function(M)? onRowTap;
  final void Function(M)? onRowDoubleTap;
  final Border rowBorder;
  final TableActionFn<M>? actions;

  const _TableRow({
    required this.item,
    required this.rowIndex,
    required this.selected,
    required this.columns,
    required this.actions,
    required this.rowBorder,
    this.onRowTap,
    this.onRowDoubleTap,
    super.key,
  });

  @override
  State<_TableRow<M>> createState() => _TableRowState<M>();
}

class _TableRowState<M extends Object> extends State<_TableRow<M>> with SingleTickerProviderStateMixin {
  final _rowGroupId = UniqueKey();
  late TableDataSource<M> dataSource = context.tableDataSource();
  late AnimationController _controller;

  Offset? _longPressOffset;

  final _contextMenuController = ContextMenuController();

  static bool get _longPressEnabled {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  void _onSecondaryTapUp(TapUpDetails details) {
    _show(details.globalPosition);
  }

  void _onTap() {
    if (!_contextMenuController.isShown) {
      return;
    }

    _hide();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _longPressOffset = details.globalPosition;
    _onLongPress();
  }

  void _onLongPress() {
    assert(_longPressOffset != null);
    _show(_longPressOffset!);
    _longPressOffset = null;
  }

  void _show(Offset position) {
    _contextMenuController.show(
      context: context,
      contextMenuBuilder: (BuildContext context) {
        return TapRegion(
          groupId: _rowGroupId,
          onTapOutside: (_) {
            ContextMenuController.removeAny();
          },
          child: DesktopTextSelectionToolbar(
            anchor: position,
            children: [
              ...widget.actions!([widget.item]).map((action) {
                if (action is AppActionDivider<M>) {
                  return const Divider();
                }

                if (action is AppActionsGroup<M>) {
                  return SubmenuButton(
                    menuChildren: [
                      ...action.items.map((item) {
                        return TapRegion(
                          groupId: _rowGroupId,
                          child: MenuItemButton(
                            leadingIcon: item.icon,
                            onPressed: item.onPressed != null
                                ? () {
                                    item.onPressed!();
                                    ContextMenuController.removeAny();
                                  }
                                : null,
                            child: Text(item.label),
                          ),
                        );
                      }),
                    ],
                    trailingIcon: const Icon(Icons.arrow_right),
                    leadingIcon: action.icon,
                    child: Text(action.label),
                  );
                }

                return MenuItemButton(
                  leadingIcon: action.icon,
                  onPressed: action.onPressed != null
                      ? () {
                          action.onPressed!();
                          ContextMenuController.removeAny();
                        }
                      : null,
                  child: Text(action.label),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _hide() {
    _contextMenuController.remove();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      value: dataSource.actionsType.isMulti && dataSource.selectedItems.isNotEmpty ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _hide();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.actions != null && _longPressEnabled ? _onLongPressStart : null,
      child: InkWell(
        onTap: () {
          _onTap();
          widget.onRowTap?.call(widget.item);
          dataSource.addOrRemoveItem(widget.item);
        },
        onDoubleTap: widget.onRowDoubleTap != null ? () => widget.onRowDoubleTap?.call(widget.item) : null,
        onSecondaryTapUp: widget.actions != null && !_longPressEnabled ? _onSecondaryTapUp : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: widget.rowBorder,
            color: widget.selected ? context.colorScheme.primary.withOpacity(0.08) : null,
          ),
          child: IntrinsicHeight(
            child: _DatasourceConfigConsumer<M, bool>(
              listener: (source) {
                if (source.actionsType.isMulti) {
                  if (source.selectedItems.isEmpty) {
                    _controller.reverse();
                  } else {
                    _controller.forward();
                  }
                }
              },
              selector: (source) => source.actionsType.isMulti,
              builder: (context, isMulti, child) {
                return Row(
                  key: ValueKey(widget.item),
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 56),
                      child: SizeTransition(
                        sizeFactor: _controller,
                        axis: Axis.horizontal,
                        child: Center(
                          child: Checkbox(
                            value: widget.selected,
                            onChanged: (_) => dataSource.addOrRemoveItem(widget.item),
                          ),
                        ),
                      ),
                    ),
                    for (final column in widget.columns)
                      column.contentBuilder(
                        context,
                        widget.item,
                        (dataSource.currentPage, widget.rowIndex),
                        context.tableState<M>().widget.controller,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
