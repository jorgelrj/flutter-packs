import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgets_pack/widgets_pack.dart';

abstract class AppChipsTextField<T> extends StatefulWidget {
  final List<T> initialItems;
  final String? labelText;
  final String? hintText;
  final ValueChanged<List<T>>? onChanged;
  final VoidCallback? onDisabledTap;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<T>? validator;

  const AppChipsTextField({
    super.key,
    this.initialItems = const [],
    this.labelText,
    this.hintText,
    this.onChanged,
    this.onDisabledTap,
    this.inputFormatters,
    this.validator,
  });

  static AppChipsTextField<String> text({
    Key? key,
    List<String> initialItems = const [],
    String? labelText,
    String? hintText,
    ValueChanged<List<String>>? onChanged,
    VoidCallback? onDisabledTap,
    List<TextInputFormatter>? inputFormatters,
    FormFieldValidator<String>? validator,
    bool showAddButton = false,
  }) {
    return _TextOnlyContent(
      key: key,
      initialItems: initialItems,
      labelText: labelText,
      hintText: hintText,
      onChanged: onChanged,
      onDisabledTap: onDisabledTap,
      inputFormatters: inputFormatters,
      validator: validator,
      showAddButton: showAddButton,
    );
  }

  static AppChipsTextField<T> dropdown<T>({
    required AppItemsFetcher<T> itemsFetcher,
    Key? key,
    List<T> initialItems = const [],
    String? labelText,
    String? hintText,
    ValueChanged<List<T>>? onChanged,
    VoidCallback? onDisabledTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return _DropdownContent<T>(
      itemsFetcher: itemsFetcher,
      key: key,
      initialItems: initialItems,
      labelText: labelText,
      hintText: hintText,
      onChanged: onChanged,
      onDisabledTap: onDisabledTap,
      inputFormatters: inputFormatters,
    );
  }

  @override
  State<AppChipsTextField<T>> createState();
}

abstract class _AppChipsTextFieldState<T> extends State<AppChipsTextField<T>> {
  late final _chipItemsNotifier = ValueNotifier<List<T>>(widget.initialItems);
  final _errorNotifier = ValueNotifier<String?>(null);

  final _widgetKey = GlobalKey();
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();

  bool get _enabled => widget.onChanged != null;

  EdgeInsets get _inputPadding => EdgeInsets.zero;

  void _textControllerListener() {}

  void _textFocusNodeListener() {}

  void _afterLayout() {}

  void _handleItem(T item) {
    final items = List.of(_chipItemsNotifier.value);

    if (items.contains(item)) {
      items.remove(item);
    } else {
      items.add(item);
    }

    _chipItemsNotifier.value = items;
    _textController.clear();
    _onItemsChange();
  }

  void _onItemsChange() {
    widget.onChanged?.call(_chipItemsNotifier.value);
  }

  void _onDispose() {}

  @override
  void initState() {
    super.initState();

    _textController.addListener(_textControllerListener);
    _textFocusNode.addListener(_textFocusNodeListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterLayout();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _errorNotifier.dispose();
    _onDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide.none,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              disabledBorder: border,
            ),
      ),
      child: GestureDetector(
        onTap: () {
          if (_enabled) {
            _textFocusNode.requestFocus();
          } else {
            widget.onDisabledTap?.call();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                key: _widgetKey,
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(kXXSSize),
                  ),
                  color: context.wpColorsConfig.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: ValueListenableBuilder<List<T>>(
                    valueListenable: _chipItemsNotifier,
                    builder: (context, items, child) {
                      final hasItems = items.isNotEmpty;

                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...items.map(
                            (item) {
                              return AppChip(
                                label: item.toString(),
                                onDelete: () {
                                  _handleItem(item);
                                  _textFocusNode.requestFocus();
                                },
                                selected: true,
                                borderRadius: BorderRadius.circular(25),
                                backgroundColor: context.colorScheme.onSecondaryContainer,
                                onBackgroundColor: context.colorScheme.secondaryContainer,
                                checkIcon: Icons.check_circle,
                              );
                            },
                          ),
                          IntrinsicWidth(
                            child: Container(
                              padding: _inputPadding,
                              constraints: BoxConstraints(
                                minWidth: hasItems ? 0 : 350,
                              ),
                              child: AppTextFormField(
                                enabled: _enabled,
                                focusNode: _textFocusNode,
                                controller: _textController,
                                labelText: !hasItems ? widget.labelText : null,
                                hintText: !hasItems ? widget.hintText : null,
                                maxLines: null,
                                border: border,
                                inputFormatters: widget.inputFormatters,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: _errorNotifier,
              builder: (context, error, child) {
                if (error == null) {
                  return const SizedBox();
                }

                return BodySmall(
                  error,
                ).color(context.colorScheme.error);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TextOnlyContent extends AppChipsTextField<String> {
  final bool showAddButton;

  const _TextOnlyContent({
    super.key,
    super.initialItems,
    super.labelText,
    super.hintText,
    super.onChanged,
    super.onDisabledTap,
    super.inputFormatters,
    super.validator,
    this.showAddButton = false,
  });

  @override
  State<AppChipsTextField<String>> createState() => _TextOnlyContentState();
}

class _TextOnlyContentState extends _AppChipsTextFieldState<String> {
  @override
  _TextOnlyContent get widget => super.widget as _TextOnlyContent;

  final _keyboardFocusNode = FocusNode();

  @override
  EdgeInsets get _inputPadding {
    return widget.showAddButton ? const EdgeInsets.only(right: 48) : EdgeInsets.zero;
  }

  void _removeLastItem() {
    if (_chipItemsNotifier.value.isEmpty) {
      return;
    }

    final lastItem = _chipItemsNotifier.value.last;
    _handleItem(lastItem);

    _textController.text = lastItem;
  }

  @override
  void _textControllerListener() {
    _errorNotifier.value = null;
    final text = _textController.text;

    final shouldAddChips = text.contains(RegExp(r'[,\n]'));
    if (!shouldAddChips) {
      return;
    }

    final chips = text.split(RegExp(r'[,\n]')).map((s) => s.trim()).whereNot((s) => s.isEmpty);

    for (final chip in chips) {
      final error = widget.validator?.call(chip);

      if (error == null) {
        _handleItem(chip);
      } else {
        _errorNotifier.value = error;
      }
    }

    _textController.text = _textController.text.replaceAll('\n', '');
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (key) {
        if (key is KeyDownEvent && key.logicalKey == LogicalKeyboardKey.backspace) {
          if (_textController.text.isEmpty) {
            _removeLastItem();
          }
        }
      },
      child: Stack(
        children: [
          super.build(context),
          if (widget.showAddButton)
            Positioned(
              bottom: 0,
              right: 0,
              child: ListenableBuilder(
                listenable: _textController,
                builder: (context, child) {
                  final hasText = _textController.text.isNotEmpty;

                  return hasText ? child! : const SizedBox();
                },
                child: ValueListenableBuilder<String?>(
                  valueListenable: _errorNotifier,
                  builder: (context, error, child) {
                    final hasError = error != null;

                    return Padding(
                      padding: DimensionUtils(4).all.xxs + (hasError ? kSpacer.bottom.xs : kSpacer.all.none),
                      child: AppButton.icon(
                        tooltip: 'Click enter/comma to add',
                        onPressed: () {
                          final error = widget.validator?.call(_textController.text);

                          if (error == null) {
                            _handleItem(_textController.text);
                            _textFocusNode.requestFocus();
                          } else {
                            _errorNotifier.value = error;
                          }
                        },
                        fillColor: context.colorScheme.secondaryContainer,
                        icon: Icon(
                          Icons.send,
                          size: 24,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DropdownContent<T> extends AppChipsTextField<T> {
  final AppItemsFetcher<T> itemsFetcher;

  const _DropdownContent({
    required this.itemsFetcher,
    super.key,
    super.initialItems,
    super.labelText,
    super.hintText,
    super.onChanged,
    super.onDisabledTap,
    super.inputFormatters,
  });

  @override
  State<AppChipsTextField<T>> createState() => _DropdownContentState<T>();
}

class _DropdownContentState<T> extends _AppChipsTextFieldState<T> {
  @override
  _DropdownContent<T> get widget => super.widget as _DropdownContent<T>;

  RenderBox get _renderBox {
    return _widgetKey.currentContext!.findRenderObject()! as RenderBox;
  }

  Size get _widgetSize {
    return _renderBox.size;
  }

  final _layerLink = LayerLink();
  final _searchDebouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  final _itemNotifier = ValueNotifier<List<T>>([]);
  final _filteredItemsNotifier = ValueNotifier<List<T>>([]);

  bool _loadedAll = false;
  bool _loading = false;

  late OverlayEntry _overlayEntry;

  Future<void> _search(String search) async {
    if (_loading) {
      return;
    }

    _setLoading(true);

    await switch (widget.itemsFetcher) {
      (AppRemoteListItemsFetcher<T>()) => _remoteListFetcher(search),
      (AppLocalItemsFetcher<T>()) => _localListFetcher(search),
      (_) => throw UnimplementedError(),
    };

    _setLoading(false);

    _filteredItemsNotifier.value = _itemNotifier.value.where((item) {
      return item.toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  Future<void> _localListFetcher(String search) async {
    if (_loadedAll) {
      return;
    }

    final fetcher = widget.itemsFetcher as AppLocalItemsFetcher<T>;
    final items = await fetcher.items;

    setState(() => _loadedAll = true);

    _itemNotifier.value = items;
  }

  Future<void> _remoteListFetcher(String search) async {
    if (_loadedAll) {
      return;
    }

    final fetcher = widget.itemsFetcher as AppRemoteListItemsFetcher<T>;
    final items = await fetcher.getItems();

    setState(() => _loadedAll = true);

    _itemNotifier.value = items;
  }

  void _setLoading(bool loading) {
    if (loading == _loading) {
      return;
    }

    _loading = loading;
    _overlayEntry.markNeedsBuild();
  }

  @override
  void _textControllerListener() {
    _searchDebouncer.run(
      () => _search(_textController.text),
    );
    _overlayEntry.markNeedsBuild();
  }

  @override
  void _textFocusNodeListener() {
    if (mounted) {
      if (_textFocusNode.hasFocus) {
        Overlay.maybeOf(context)?.insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    }
  }

  @override
  void _onItemsChange() {
    _textFocusNode.unfocus();

    super._onItemsChange();
  }

  @override
  void _afterLayout() {
    _overlayEntry = OverlayEntry(
      maintainState: true,
      canSizeOverlay: true,
      builder: (context) {
        return Positioned(
          width: _widgetSize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomLeft,
            showWhenUnlinked: false,
            child: Material(
              type: MaterialType.transparency,
              child: _overlayContent,
            ),
          ),
        );
      },
    );
  }

  @override
  void _onDispose() {
    _itemNotifier.dispose();
    _filteredItemsNotifier.dispose();
  }

  Widget get _overlayContent {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_loading) const LinearProgressIndicator(),
        Flexible(
          child: TextFieldTapRegion(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: context.wpColorsConfig.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
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
              child: ValueListenableBuilder<List<T>>(
                valueListenable: _filteredItemsNotifier,
                builder: (context, items, child) {
                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Material(
                    type: MaterialType.transparency,
                    child: ListView.separated(
                      itemCount: items.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return ListTile(
                          title: Text(item.toString()),
                          onTap: () => _handleItem(item),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: super.build(context),
    );
  }
}
