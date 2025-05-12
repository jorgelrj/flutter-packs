part of 'filter.dart';

class AppListFilter<T extends Object> extends AppFilter<T> {
  final List<T> items;
  final String label;
  final ValueChanged<T?> onChanged;
  final T? initialValue;
  final String Function(T)? asString;

  const AppListFilter({
    required this.label,
    required this.onChanged,
    required this.items,
    this.initialValue,
    this.asString,
    super.key,
  });

  @override
  State<AppFilter<T>> createState() => _AppListFilterState<T>();
}

class _AppListFilterState<T extends Object> extends _AppFilterState<T> {
  @override
  AppListFilter<T> get widget => super.widget as AppListFilter<T>;

  late final _itemNotifier = ValueNotifier<T?>(
    widget.initialValue,
  );

  late final _textController = TextEditingController(
    text: _formattedItem,
  );

  late final _overlayController = AppOverlayPortalController(
    onHide: _setValue,
  );

  final _link = LayerLink();

  String get _formattedItem {
    if (_itemNotifier.value == null) {
      return '';
    }

    if (widget.asString != null) {
      return widget.asString!(_itemNotifier.value!);
    }

    return _itemNotifier.value.toString();
  }

  void _itemNotifierListener() {
    _textController.text = _formattedItem;
  }

  void _setValue() {
    widget.onChanged(_itemNotifier.value);
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
    AppTableView.maybeOf(context)?.controller.reload();
  }

  @override
  void initState() {
    super.initState();

    _itemNotifier.addListener(_itemNotifierListener);
  }

  @override
  void dispose() {
    _textController.dispose();
    _itemNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 300,
                constraints: const BoxConstraints(maxHeight: 500),
                child: TapRegion(
                  onTapOutside: (_) => _overlayController.hide(),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];

                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              widget.asString?.call(item) ?? item.toString(),
                            ),
                            onTap: () {
                              _itemNotifier.value = item;
                              _setValue();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: ListenableBuilder(
          listenable: _itemNotifier,
          builder: (context, child) {
            final hasItem = _itemNotifier.value != null;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      [
                        widget.label,
                        if (hasItem) _formattedItem,
                      ].join(': '),
                    ),
                  ),
                  if (!hasItem) ...[
                    const Spacing(),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ],
              ),
              selected: hasItem,
              showCheckmark: false,
              deleteIconColor: context.colorScheme.onPrimary,
              onSelected: (_) {
                _overlayController.show();
              },
              onDeleted: hasItem
                  ? () {
                      _itemNotifier.value = null;
                      _setValue();
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
