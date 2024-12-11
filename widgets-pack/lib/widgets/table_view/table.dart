import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:widgets_pack/widgets_pack.dart';

const _columnHeight = 56.0;

class AppTableView<M extends Object> extends StatefulWidget {
  final AppTableViewController<M> controller;
  final List<TableColumn<M>> columns;
  final AppTableViewConfig<M> config;
  final ScrollController? horizontalScrollController;
  final WidgetBuilder? aboveTableBuilder;
  final Widget Function(BuildContext context, List<Widget> filters)? filtersBuilder;

  const AppTableView({
    required this.controller,
    required this.columns,
    this.config = const AppTableViewConfig(),
    this.horizontalScrollController,
    this.aboveTableBuilder,
    this.filtersBuilder,
    super.key,
  });

  @override
  State<AppTableView<M>> createState() => _AppTableViewState<M>();

  static _AppTableViewState<M> of<M extends Object>(BuildContext context) {
    return context.findAncestorStateOfType<_AppTableViewState<M>>()!;
  }

  static _AppTableViewState<M>? maybeOf<M extends Object>(BuildContext context) {
    return context.findAncestorStateOfType<_AppTableViewState<M>>();
  }
}

class _AppTableViewState<M extends Object> extends State<AppTableView<M>> {
  late final _pageSizeNotifier = ValueNotifier<int>(
    controller.pageSize,
  );
  late final _pageNotifier = ValueNotifier<int>(
    controller.currentPage,
  );
  late final _hasSelectionNotifier = ValueNotifier<bool>(
    controller.selectedItems.isNotEmpty,
  );
  late final _showCheckBoxNotifier = ValueNotifier<bool>(
    controller.actionsType != TableActionsType.none,
  );

  final _hoveredRowNotifier = ValueNotifier<int?>(null);

  late final _horizontalScrollController = widget.horizontalScrollController ?? ScrollController();

  final _linkedScrollGroup = LinkedScrollControllerGroup();
  late final _verticalScrollController = _linkedScrollGroup.addAndGet();
  late final _checkboxScrollController = _linkedScrollGroup.addAndGet();
  late final _actionsScrollController = _linkedScrollGroup.addAndGet();

  AppTableViewController<M> get controller => widget.controller;

  AppTableViewConfig<M> get config => widget.config;

  void _controllerListener() {
    _pageSizeNotifier.value = controller.pageSize;
    _hasSelectionNotifier.value = controller.selectedItems.isNotEmpty;
    _showCheckBoxNotifier.value = controller.actionsType != TableActionsType.none;
    _pageNotifier.value = controller.currentPage;

    widget.config.onItemsSelected?.call(widget.controller.selectedItems);
  }

  @override
  void initState() {
    super.initState();

    controller
      ..actionsType = config.actionType
      ..pageSize = config.pageSize
      ..addListener(_controllerListener);
  }

  @override
  void didUpdateWidget(covariant AppTableView<M> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.config.actionType != config.actionType) {
      controller.actionsType = config.actionType;
    }

    if (oldWidget.config.pageSize != config.pageSize) {
      controller.pageSize = config.pageSize;
    }
  }

  @override
  void dispose() {
    controller.removeListener(_controllerListener);

    if (widget.horizontalScrollController == null) _horizontalScrollController.dispose();

    _pageSizeNotifier.dispose();
    _hasSelectionNotifier.dispose();
    _verticalScrollController.dispose();
    _checkboxScrollController.dispose();
    _showCheckBoxNotifier.dispose();
    _actionsScrollController.dispose();
    _pageNotifier.dispose();
    _hoveredRowNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showActionsColumn =
        (config.showActionsAsTrailingIcon && config.actions != null) || config.persistentTrailingActions != null;
    final showEmptyState = config.emptyStateBuilder != null && !controller.loading && controller.items.isEmpty;
    final showFiltersRow = config.filters.isNotEmpty || config.action != null;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _hasSelectionNotifier,
              builder: (context, showActions, child) {
                if (showActions && config.actions != null) {
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return AppTableActionsRow(
                        items: controller.selectedItems,
                        actions: config.actions,
                        onClearAll: controller.clearSelection,
                        itemsSelectedTextBuilder: widget.config.itemsSelectedString,
                      );
                    },
                  );
                }

                if (showFiltersRow) {
                  return widget.filtersBuilder?.call(
                        context,
                        config.filters,
                      ) ??
                      AppTableFilterRow(
                        filters: config.filters,
                        headerAction: config.action,
                      );
                }

                return const SizedBox();
              },
            ),
            if (widget.aboveTableBuilder != null) widget.aboveTableBuilder!(context),
            if (showEmptyState) config.emptyStateBuilder!(context) else Flexible(child: child!),
          ],
        );
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          overscroll: false,
          physics: const ClampingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ValueListenableBuilder<int>(
                valueListenable: _pageSizeNotifier,
                builder: (context, pageSize, child) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _columnHeight * (pageSize + 1),
                    ),
                    child: child,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CheckBoxesColumn(
                      controller: controller,
                      checkboxScrollController: _checkboxScrollController,
                      hoveredRowNotifier: _hoveredRowNotifier,
                      pageSizeNotifier: _pageSizeNotifier,
                      showCheckBoxNotifier: _showCheckBoxNotifier,
                    ),
                    Expanded(
                      child: ScrollOverflowBuilder(
                        controller: _horizontalScrollController,
                        child: ValueListenableBuilder<int>(
                          valueListenable: _pageSizeNotifier,
                          builder: (context, pageSize, child) {
                            return _TableView<M>(
                              horizontalScrollController: _horizontalScrollController,
                              verticalScrollController: _verticalScrollController,
                              columns: widget.columns,
                              controller: controller,
                              config: config,
                              pageSize: pageSize + 1,
                              hoveredRowNotifier: _hoveredRowNotifier,
                            );
                          },
                        ),
                      ),
                    ),
                    if (showActionsColumn)
                      _ActionsColumn(
                        actionsScrollController: _actionsScrollController,
                        controller: controller,
                        config: config,
                        hoveredRowNotifier: _hoveredRowNotifier,
                      ),
                  ],
                ),
              ),
            ),
            if (widget.config.showPagination) ...[
              const Spacing(),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      BodyLarge(
                        isSmallScreen
                            ? context.wpStringsConfig.table.rowsPerPage.short
                            : context.wpStringsConfig.table.rowsPerPage.long,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _pageSizeNotifier,
                        builder: (context, size, child) {
                          final configSizes = Set.of(config.pageSizes);
                          final availableSizes = configSizes..remove(size);

                          return MenuAnchor(
                            style: const MenuStyle(
                              maximumSize: WidgetStatePropertyAll(Size.fromWidth(50)),
                            ),
                            menuChildren: [
                              ...availableSizes.map((size) {
                                return ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 45,
                                  ),
                                  child: MenuItemButton(
                                    onPressed: () {
                                      controller
                                        ..pageSize = size
                                        ..reload();
                                    },
                                    child: Text(
                                      size.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            builder: (context, controller, child) {
                              return IntrinsicWidth(
                                child: AppTextFormField(
                                  key: ValueKey(size),
                                  onTap: controller.toggle,
                                  readOnly: true,
                                  initialValue: size.toString(),
                                  filled: true,
                                  fillColor: context.colorScheme.surfaceBright,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (isSmallScreen) const Spacer(),
                      AppButton.icon(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: controller.previousPage,
                      ),
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          return BodyLarge(
                            [
                              (controller.pageSize * controller.currentPage) + 1,
                              '-',
                              controller.pageSize * (controller.currentPage + 1),
                              if (controller.isMaxItemsKnown) ...[
                                context.wpStringsConfig.table.of,
                                controller.maxItems,
                              ],
                            ].join(' '),
                          );
                        },
                      ),
                      AppButton.icon(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: controller.nextPage,
                      ),
                    ].addSpacingBetween(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionsColumn<M extends Object> extends StatelessWidget {
  final ScrollController actionsScrollController;
  final AppTableViewController<M> controller;
  final AppTableViewConfig<M> config;
  final ValueNotifier<int?> hoveredRowNotifier;

  const _ActionsColumn({
    required this.actionsScrollController,
    required this.controller,
    required this.config,
    required this.hoveredRowNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return IntrinsicWidth(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.colorScheme.onSurfaceVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                height: _columnHeight,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: actionsScrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      controller.pageSize,
                      (index) {
                        final item = controller.itemAtIndex(index);
                        final visible = item != null;
                        final isLastRow = index == controller.pageSize - 1;

                        return ValueListenableBuilder<int?>(
                          valueListenable: hoveredRowNotifier,
                          builder: (context, hoveredRow, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: hoveredRow == index + 1 ? context.colorScheme.surfaceContainer : null,
                                border: isLastRow && !config.showPagination
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          color: context.colorScheme.onSurfaceVariant,
                                          width: 0.5,
                                        ),
                                      ),
                              ),
                              height: _columnHeight,
                              child: child,
                            );
                          },
                          child: Row(
                            children: visible
                                ? [
                                    ...?config.persistentTrailingActions?.call(item).map((action) {
                                      if (action is AppActionsGroup) {
                                        return MenuAnchor(
                                          menuChildren: [
                                            ...config.actions!([item]).toAnchorChildren(),
                                          ],
                                          builder: (context, controller, child) {
                                            return AppButton.icon(
                                              onPressed: controller.toggle,
                                              icon: action.icon,
                                            );
                                          },
                                        );
                                      } else {
                                        return AppButton.icon(
                                          onPressed: action.onPressed,
                                          icon: action.icon,
                                        );
                                      }
                                    }),
                                    if (config.actions != null)
                                      MenuAnchor(
                                        menuChildren: [
                                          ...config.actions!([item]).toAnchorChildren(),
                                        ],
                                        builder: (context, controller, child) {
                                          return AppButton.icon(
                                            onPressed: controller.toggle,
                                            icon: const Icon(Icons.more_horiz),
                                          );
                                        },
                                      ),
                                  ]
                                : [],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CheckBoxesColumn<M extends Object> extends StatelessWidget {
  final ValueNotifier<int> pageSizeNotifier;
  final ValueNotifier<bool> showCheckBoxNotifier;
  final ValueNotifier<int?> hoveredRowNotifier;
  final ScrollController checkboxScrollController;
  final AppTableViewController<M> controller;

  const _CheckBoxesColumn({
    required this.pageSizeNotifier,
    required this.showCheckBoxNotifier,
    required this.hoveredRowNotifier,
    required this.checkboxScrollController,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: pageSizeNotifier,
      builder: (context, pageSize, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: showCheckBoxNotifier,
              builder: (context, showCheckBox, child) {
                if (showCheckBox) {
                  return child!;
                }

                return const SizedBox(
                  height: _columnHeight,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.colorScheme.onSurfaceVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                height: _columnHeight,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final selected = controller.allItemsSelected;

                    if (controller.actionsType != TableActionsType.multi) {
                      return const SizedBox(
                        width: 32,
                      );
                    }

                    return Checkbox(
                      side: WidgetStateBorderSide.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return BorderSide(color: context.colorScheme.primary);
                        }

                        return BorderSide(color: context.colorScheme.onSurface);
                      }),
                      value: selected,
                      onChanged: (value) => controller.handleSelectAll(),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: checkboxScrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    pageSize,
                    (index) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: showCheckBoxNotifier,
                        builder: (context, showCheckBox, child) {
                          if (!showCheckBox) {
                            return const SizedBox(
                              height: _columnHeight,
                            );
                          }

                          return ValueListenableBuilder<int?>(
                            valueListenable: hoveredRowNotifier,
                            builder: (context, hoveredIndex, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: hoveredIndex == index + 1 ? context.colorScheme.surfaceContainer : null,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: context.colorScheme.onSurfaceVariant,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                height: _columnHeight,
                                child: child,
                              );
                            },
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (context, child) {
                                final selected = controller.itemAtIndexIsSelected(index);
                                final item = controller.itemAtIndex(index);

                                return Visibility(
                                  visible: item != null,
                                  replacement: const SizedBox(width: 32),
                                  child: Checkbox(
                                    side: WidgetStateBorderSide.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return BorderSide(color: context.colorScheme.primary);
                                      }

                                      return BorderSide(color: context.colorScheme.onSurface);
                                    }),
                                    value: selected,
                                    onChanged: (value) => controller.handleItemTapAtIndex(index),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TableView<M extends Object> extends StatefulWidget {
  final List<TableColumn<M>> columns;
  final AppTableViewController<M> controller;
  final AppTableViewConfig<M> config;
  final int pageSize;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;
  final ValueNotifier<int?> hoveredRowNotifier;

  const _TableView({
    required this.columns,
    required this.controller,
    required this.pageSize,
    required this.config,
    required this.horizontalScrollController,
    required this.verticalScrollController,
    required this.hoveredRowNotifier,
    super.key,
  });

  @override
  State<_TableView<M>> createState() => _TableViewState<M>();
}

class _TableViewState<M extends Object> extends State<_TableView<M>> {
  final _contextMenuController = ContextMenuController();
  final _menuGroupId = UniqueKey();

  late final _loadingNotifier = ValueNotifier<bool>(
    widget.controller.loading,
  );

  void _controllerListener() {
    _loadingNotifier.value = widget.controller.loading;
  }

  Map<Type, GestureRecognizerFactory> _buildRowRecognizers(int index) {
    if (index == 0) {
      return const {};
    }

    return <Type, GestureRecognizerFactory>{
      DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        DoubleTapGestureRecognizer.new,
        (recognizer) {
          recognizer.onDoubleTap = () {
            final item = widget.controller.itemAtIndex(index - 1);

            if (item != null) {
              widget.config.onDoubleTapRow?.call(item);
            }
          };
        },
      ),
      LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        LongPressGestureRecognizer.new,
        (recognizer) {
          recognizer.onLongPressStart = (details) {
            _show(details.globalPosition, index);
          };
        },
      ),
      TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        TapGestureRecognizer.new,
        (recognizer) {
          recognizer
            ..onTap = () {
              widget.controller.handleItemTapAtIndex(index - 1);
            }
            ..onSecondaryTapUp = (details) {
              _show(details.globalPosition, index);
            };
        },
      ),
    };
  }

  void _hide() {
    _contextMenuController.remove();
  }

  void _show(Offset position, int rowIndex) {
    final realIndex = rowIndex - 1;
    final item = widget.controller.currentPageItems.elementAtOrNull(realIndex);

    if (item == null) {
      return;
    }

    final child = TapRegion(
      groupId: _menuGroupId,
      onTapOutside: (_) => ContextMenuController.removeAny(),
      child: DesktopTextSelectionToolbar(
        anchor: position,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...?widget.config.actions?.call([item]).map((action) {
                  if (action is AppActionDivider<M>) {
                    return const Divider();
                  }

                  if (action is AppActionsGroup<M>) {
                    return MenuAnchor(
                      style: const MenuStyle(
                        alignment: Alignment.topRight,
                      ),
                      menuChildren: [
                        ...action.items.map((item) {
                          return TapRegion(
                            groupId: _menuGroupId,
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
                      builder: (context, controller, child) {
                        return MenuItemButton(
                          leadingIcon: action.icon,
                          trailingIcon: const Icon(Icons.arrow_right),
                          onPressed: controller.toggle,
                          child: Text(action.label),
                        );
                      },
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
          ),
        ],
      ),
    );

    _contextMenuController.show(
      context: context,
      contextMenuBuilder: (context) {
        return child;
      },
    );
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _loadingNotifier.dispose();
    _hide();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loadingNotifier,
      builder: (context, loading, child) {
        return TableView.builder(
          key: const Key('table-view'),
          columnCount: widget.columns.length,
          rowCount: widget.pageSize,
          pinnedRowCount: 1,
          pinnedColumnCount: widget.config.fixedColumns,
          horizontalDetails: ScrollableDetails.horizontal(
            controller: widget.horizontalScrollController,
          ),
          verticalDetails: ScrollableDetails.vertical(
            controller: widget.verticalScrollController,
          ),
          columnBuilder: (index) {
            final column = widget.columns.elementAt(index);
            final isLast = index == widget.columns.length - 1;

            return TableSpan(
              extent: isLast
                  ? MaxSpanExtent(
                      const RemainingSpanExtent(),
                      FixedTableSpanExtent(column.width),
                    )
                  : FixedTableSpanExtent(column.width),
            );
          },
          rowBuilder: (index) {
            final isHeader = index == 0;
            final isLastRow = index == widget.pageSize - 1;

            return TableSpan(
              cursor: isHeader ? SystemMouseCursors.basic : SystemMouseCursors.click,
              backgroundDecoration: TableSpanDecoration(
                border: (isLastRow && !widget.config.showPagination)
                    ? null
                    : SpanBorder(
                        trailing: BorderSide(
                          color: context.colorScheme.onSurfaceVariant,
                          width: 0.5,
                        ),
                      ),
              ),
              extent: const FixedTableSpanExtent(_columnHeight),
              recognizerFactories: _buildRowRecognizers(index),
            );
          },
          cellBuilder: (context, vicinity) {
            final column = widget.columns[vicinity.column];

            if (vicinity.row == 0) {
              return TableViewCell(
                child: column.labelBuilder(context),
              );
            }

            return TableViewCell(
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, child) {
                  final item = widget.controller.currentPageItems.elementAtOrNull(
                    vicinity.row - 1,
                  );

                  if (loading) {
                    return Skeletonizer(
                      child: Text(
                        BoneMock.fullName,
                      ),
                    );
                  }

                  if (item == null) {
                    return const SizedBox();
                  }

                  return AppTableViewColumnBuilder<M>(
                    column: column,
                    item: item,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
