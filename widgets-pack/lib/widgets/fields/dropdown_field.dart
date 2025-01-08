import 'dart:async';

import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppDropDownFormField<T extends Object> extends StatefulWidget {
  final AppItemsFetcher<T> fetcher;
  final AppItemsHandler<T> handler;
  final String? labelText;
  final TextStyle? labelStyle;
  final String? hintText;
  final AppItemsValidator<T>? validator;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? overlayOpenBorder;
  final BoxBorder? overlayBorder;
  final EdgeInsets? inputContentPadding;
  final EdgeInsets? tilesContentPadding;
  final bool showTrailing;
  final AppTextFormFieldErrorType errorType;
  final Widget Function(T item, bool selected, VoidCallback onTap)? tileBuilder;
  final bool enabled;
  final bool updateTextOnChanged;
  final bool? filled;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool requestFocusOnInitState;
  final int? minLengthForSearch;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Color? overlayColor;
  final BorderRadius? overlayBorderRadius;
  final Duration debounceDuration;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingBuilder;
  final TextStyle? style;
  final bool loading;
  final bool showClearButton;
  final bool readOnly;
  final Color? barrierColor;
  final bool openAsBottomSheet;
  final bool adaptive;

  const AppDropDownFormField({
    required this.fetcher,
    required this.handler,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.validator,
    this.border,
    this.focusedBorder,
    this.overlayOpenBorder,
    this.overlayBorder,
    this.inputContentPadding,
    this.tilesContentPadding,
    this.showTrailing = true,
    this.errorType = AppTextFormFieldErrorType.string,
    this.tileBuilder,
    this.enabled = true,
    this.updateTextOnChanged = true,
    this.filled,
    this.fillColor,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.requestFocusOnInitState = false,
    this.minLengthForSearch,
    this.controller,
    this.focusNode,
    this.overlayColor,
    this.overlayBorderRadius,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.emptyBuilder,
    this.loadingBuilder,
    this.style,
    this.loading = false,
    this.showClearButton = true,
    this.readOnly = false,
    this.barrierColor,
    this.openAsBottomSheet = false,
    super.key,
  }) : adaptive = false;

  const AppDropDownFormField.adaptive({
    required this.fetcher,
    required this.handler,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.validator,
    this.border,
    this.focusedBorder,
    this.overlayOpenBorder,
    this.overlayBorder,
    this.inputContentPadding,
    this.tilesContentPadding,
    this.showTrailing = true,
    this.errorType = AppTextFormFieldErrorType.string,
    this.tileBuilder,
    this.enabled = true,
    this.updateTextOnChanged = true,
    this.filled,
    this.fillColor,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.requestFocusOnInitState = false,
    this.minLengthForSearch,
    this.controller,
    this.focusNode,
    this.overlayColor,
    this.overlayBorderRadius,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.emptyBuilder,
    this.loadingBuilder,
    this.style,
    this.loading = false,
    this.showClearButton = true,
    this.readOnly = false,
    this.barrierColor,
    this.openAsBottomSheet = false,
    super.key,
  }) : adaptive = true;

  @override
  State<AppDropDownFormField<T>> createState() => _AppDropDownFormFieldState<T>();
}

class _AppDropDownFormFieldState<T extends Object> extends State<AppDropDownFormField<T>> {
  final _widgetKey = GlobalKey();

  RenderBox? get _renderBox {
    return _widgetKey.currentContext?.findRenderObject() as RenderBox?;
  }

  Size? get _widgetSize {
    return _renderBox?.size;
  }

  final _layerLink = LayerLink();

  late final _textController = widget.controller ?? TextEditingController();
  late final _textFocusNode = widget.focusNode ?? FocusNode();

  late final _searchDebouncer = Debouncer(
    duration: widget.debounceDuration,
  );

  final _itemNotifier = ValueNotifier<List<T>>([]);
  final _filteredItemsNotifier = ValueNotifier<List<T>>([]);
  final _showingOverlayNotifier = ValueNotifier<bool>(false);
  final _highlightedIndexNotifier = ValueNotifier<int>(0);

  late final _selectedItemNotifier = ValueNotifier<List<T>>(
    switch (widget.handler) {
      final AppSingleItemHandler<T> handler => [handler.initialValue].whereNotNull().toList(),
      final AppMultipleItemsHandler<T> handler => handler.initialValue,
    },
  );

  late final _hasItemsNotifier = ValueNotifier<bool>(
    _selectedItemNotifier.value.isNotEmpty,
  );

  bool get _openAsBottomSheet {
    final asBottomSheet = widget.openAsBottomSheet || (widget.adaptive && context.screenSize.width < 600);

    return asBottomSheet;
  }

  bool _loadedAll = false;
  late bool _loading = widget.loading;

  String? _lastSearch;

  OverlayEntry? _overlayEntry;

  Future<void> _search(String search, {bool fromInputChange = false}) async {
    if (!fromInputChange) {
      return;
    }

    if (widget.minLengthForSearch != null) {
      if (search.length < widget.minLengthForSearch!) {
        return;
      }
    }

    _lastSearch = search;

    await switch (widget.fetcher) {
      (AppRemoteListItemsFetcher<T>()) => _remoteListFetcher(search),
      (AppLocalItemsFetcher<T>()) => _localListFetcher(search),
      (AppRemoteSearchListItemsFetcher<T>()) => _remoteSearchFetcher(search),
      (_) => throw UnimplementedError('Fetcher not implemented'),
    };

    _filteredItemsNotifier.value = _itemNotifier.value.where((item) {
      return widget.handler.filter(item, search);
    }).toList();
  }

  Future<void> _localListFetcher(String search) async {
    if (_loadedAll) {
      return;
    }

    final fetcher = widget.fetcher as AppLocalItemsFetcher<T>;
    final items = fetcher.items;

    setState(() => _loadedAll = true);

    _itemNotifier.value = items;
  }

  Future<void> _remoteListFetcher(String search) async {
    if (_loadedAll || _loading) {
      return;
    }

    _setLoading(true);

    final fetcher = widget.fetcher as AppRemoteListItemsFetcher<T>;
    final items = await fetcher.getItems();

    setState(() {
      _loadedAll = true;
      _loading = false;
    });

    _itemNotifier.value = items;
  }

  Future<void> _remoteSearchFetcher(String search) async {
    _filteredItemsNotifier.value = <T>[];
    _itemNotifier.value = <T>[];

    _setLoading(true);

    final fetcher = widget.fetcher as AppRemoteSearchListItemsFetcher<T>;
    final items = await fetcher.getItems(search);

    if (search != _lastSearch) {
      return;
    }

    _setLoading(false);

    _itemNotifier.value = items;
  }

  void _setLoading(bool loading) {
    if (loading == _loading) {
      return;
    }

    _loading = loading;
    _overlayEntry?.markNeedsBuild();
  }

  void _textControllerListener() {
    _searchDebouncer.run(
      () => _search(_textController.text),
    );

    _overlayEntry?.markNeedsBuild();
  }

  void _textFocusNodeListener() {
    if (mounted) {
      if (_textFocusNode.hasFocus) {
        if (_openAsBottomSheet) {
          _showBottomSheet();
        } else if (!_openAsBottomSheet && _overlayEntry != null) {
          _showOverlay();
        }
      } else if (!_openAsBottomSheet) {
        _hideOverlay();
      }
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _showingOverlayNotifier.value = false;

    _setTextValue();
  }

  void _showOverlay() {
    _textController.clear();
    Overlay.maybeOf(
      context,
      rootOverlay: true,
    )?.insert(_overlayEntry!);
    _showingOverlayNotifier.value = true;
  }

  Future<void> _showBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        _search('', fromInputChange: true);

        return _BottomSheetContent(
          onTextChanged: (value) => _search(value, fromInputChange: true),
          itemsList: _itemsListBuilder(),
          labelText: widget.labelText,
          hintText: widget.hintText,
        );
      },
    );

    _textFocusNode.unfocus();
  }

  FutureOr<void> _onItemsChange() async {
    switch (widget.handler) {
      case final AppSingleItemHandler<T> handler:
        handler.onChanged(_selectedItemNotifier.value.firstOrNull);
        _textFocusNode.unfocus();

      case final AppMultipleItemsHandler<T> handler:
        handler.onChanged(_selectedItemNotifier.value);
    }

    _hasItemsNotifier.value = _selectedItemNotifier.value.isNotEmpty;

    if (!_hasItemsNotifier.value) {
      _setTextValue();
    }
  }

  void _afterLayout() {
    _setTextValue();

    if (_renderBox == null) {
      return;
    }

    final barrierColor = widget.barrierColor ?? context.wpWidgetsConfig.dropdownInput?.barrierColor;

    _overlayEntry ??= OverlayEntry(
      maintainState: true,
      canSizeOverlay: true,
      builder: (context) {
        const maxHeight = 200.0;
        final widgetPosition = _renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
        final widgetSize = _widgetSize ?? Size.zero;
        final availableSpace = MediaQuery.of(context).size.height - widgetPosition.dy - widgetSize.height;

        final openAbove = availableSpace < 128;

        return Stack(
          children: [
            if (barrierColor != null)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: barrierColor,
              ),
            Positioned(
              width: widgetSize.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: openAbove ? Alignment.topLeft : Alignment.bottomLeft,
                offset: Offset(0, openAbove ? -widgetSize.height : 0),
                showWhenUnlinked: false,
                child: Material(
                  type: MaterialType.transparency,
                  child: _overlayContent(
                    maxHeight: maxHeight,
                    availableSpace: availableSpace,
                    openAbove: openAbove,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleItem(T? item) {
    return switch (widget.handler) {
      (AppSingleItemHandler<T>()) => _handleSingleItem(item),
      (AppMultipleItemsHandler<T>()) => _handleMultipleItems(item),
    };
  }

  void _handleSingleItem(T? item) {
    if (item == null) {
      _selectedItemNotifier.value = [];
    } else {
      _selectedItemNotifier.value = [item];

      if (_openAsBottomSheet) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleMultipleItems(T? item) {
    final items = List.of(_selectedItemNotifier.value);

    if (item == null) {
      items.clear();
    } else {
      if (items.contains(item)) {
        items.remove(item);
      } else {
        items.add(item);
      }
    }

    _selectedItemNotifier.value = items;
  }

  void _setTextValue() {
    final items = _selectedItemNotifier.value;

    if (items.isEmpty || !widget.updateTextOnChanged) {
      _textController.clear();
    } else {
      final text = switch (widget.handler) {
        AppSingleItemHandler<T>() => widget.handler.asString(items.first),
        AppMultipleItemsHandler<T>() => items.length > 3
            ? '${items.length} items'
            : items.take(3).map((item) => widget.handler.asString(item)).join(', '),
      };

      _textController.text = text;
    }
  }

  Widget _overlayContent({
    required double maxHeight,
    required double availableSpace,
    required bool openAbove,
  }) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading) widget.loadingBuilder?.call(context) ?? const LinearProgressIndicator(),
        Flexible(
          child: TextFieldTapRegion(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              constraints: BoxConstraints(
                maxHeight: openAbove
                    ? maxHeight
                    : availableSpace > maxHeight
                        ? maxHeight
                        : availableSpace - 16,
              ),
              decoration: BoxDecoration(
                color: widget.overlayColor ?? colorScheme.surfaceContainer,
                borderRadius: widget.overlayBorderRadius ??
                    const BorderRadius.vertical(
                      bottom: Radius.circular(4),
                    ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(5.0, 10.0),
                  ),
                ],
              ),
              child: _itemsListBuilder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemsListBuilder() {
    return ValueListenableBuilder<List<T>>(
      valueListenable: _filteredItemsNotifier,
      builder: (context, items, child) {
        if (items.isEmpty && !_loading) {
          return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
        }

        return Material(
          type: MaterialType.transparency,
          child: ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListenableBuilder(
                listenable: _selectedItemNotifier,
                builder: (context, child) {
                  final selected = _selectedItemNotifier.value.any((selected) {
                    return widget.handler.compare(selected, item);
                  });

                  void onTapItem() => _handleItem(item);

                  final textWg = Text(widget.handler.asString(item));
                  final padding = widget.tilesContentPadding;

                  if (widget.tileBuilder != null) {
                    return widget.tileBuilder!(item, selected, onTapItem);
                  }

                  return switch (widget.handler) {
                    (AppSingleItemHandler<T>()) => ListTile(
                        key: ObjectKey(item),
                        title: textWg,
                        onTap: onTapItem,
                        contentPadding: padding,
                        selected: selected,
                      ),
                    final AppMultipleItemsHandler<T> handler => CheckboxListTile(
                        key: ObjectKey(item),
                        title: textWg,
                        value: selected,
                        onChanged: (_) => onTapItem(),
                        controlAffinity: handler.controlAffinity,
                        contentPadding: padding,
                      ),
                  };
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _textController.addListener(_textControllerListener);
    _textFocusNode.addListener(_textFocusNodeListener);
    _selectedItemNotifier.addListener(_onItemsChange);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _afterLayout(),
    );
  }

  @override
  void didUpdateWidget(covariant AppDropDownFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fetcher != widget.fetcher) {
      _loadedAll = false;
      _itemNotifier.value = <T>[];

      _search(_textController.text);
    }

    if (oldWidget.handler != widget.handler) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (widget.handler) {
          case final AppSingleItemHandler<T> handler:
            final currentItem = _selectedItemNotifier.value.firstOrNull;
            final handlerItem = handler.initialValue;

            if (handlerItem != null && currentItem != null && !handler.compare(currentItem, handlerItem)) {
              _selectedItemNotifier.value = [handlerItem];
            }

            if (handlerItem == null) {
              _selectedItemNotifier.value = [];
            }

            if (currentItem == null) {
              _selectedItemNotifier.value = handlerItem != null ? [handlerItem] : [];
            }

          case final AppMultipleItemsHandler<T> handler:
            _selectedItemNotifier.value = handler.initialValue;
        }

        if (!_textFocusNode.hasFocus) {
          _setTextValue();
        }
      });
    }

    if (oldWidget.loading != widget.loading) {
      _loading = widget.loading;
    }
  }

  @override
  void dispose() {
    _itemNotifier.dispose();
    _filteredItemsNotifier.dispose();
    _selectedItemNotifier.dispose();
    _hasItemsNotifier.dispose();
    _showingOverlayNotifier.dispose();
    _highlightedIndexNotifier.dispose();

    if (widget.controller == null) {
      _textController.dispose();
    }

    if (widget.focusNode == null) {
      _textFocusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showingOverlayNotifier,
        builder: (context, showing, child) {
          return ValueListenableBuilder<bool>(
            valueListenable: _hasItemsNotifier,
            builder: (context, hasItems, child) {
              return AppTextFormField(
                requestFocusOnInitState: widget.requestFocusOnInitState,
                enabled: widget.enabled,
                controller: _textController,
                onFocusChanged: (focused) {
                  if (focused) {
                    _search(_textController.text, fromInputChange: true);
                  }
                },
                onChanged: (value) => _search(value, fromInputChange: true),
                focusNode: _textFocusNode,
                key: _widgetKey,
                labelText: widget.labelText,
                labelStyle: widget.labelStyle,
                style: widget.style,
                hintText: widget.hintText,
                border: showing ? (widget.overlayOpenBorder ?? widget.border) : widget.border,
                focusedBorder: showing ? widget.overlayOpenBorder ?? widget.focusedBorder : widget.focusedBorder,
                errorType: widget.errorType,
                contentPadding: widget.inputContentPadding,
                fillColor: widget.fillColor,
                keyboardType: widget.keyboardType,
                filled: widget.filled,
                prefixIcon: widget.prefixIcon,
                readOnly: widget.readOnly,
                validator: widget.validator != null
                    ? (_) {
                        return widget.validator!.validate(
                          _selectedItemNotifier.value,
                        );
                      }
                    : null,
                suffixIcon: widget.showTrailing && widget.updateTextOnChanged
                    ? hasItems
                        ? widget.showClearButton
                            ? AppButton.icon(
                                onPressed: () => _handleItem(null),
                                icon: const Icon(Icons.close),
                              )
                            : const Icon(Icons.arrow_drop_down)
                        : widget.suffixIcon ?? const Icon(Icons.arrow_drop_down)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final ValueChanged<String> onTextChanged;
  final String? labelText;
  final String? hintText;
  final Widget itemsList;

  const _BottomSheetContent({
    required this.onTextChanged,
    required this.itemsList,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextFormField(
          labelText: labelText,
          hintText: hintText,
          onChanged: onTextChanged,
        ),
        Flexible(
          child: itemsList,
        ),
      ],
    ).padded();
  }
}
