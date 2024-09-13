part of 'filter.dart';

class AppSearchFilter<T extends Object, M extends Object> extends AppFilter<M> {
  final Future<List<T>> Function(String search) onSearch;
  final String label;
  final ValueChanged<T?> onChanged;
  final T? initialValue;
  final String Function(T)? asString;
  final String? Function(T)? asAvatarUrl;

  const AppSearchFilter({
    required this.onSearch,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.asString,
    this.asAvatarUrl,
    super.key,
  });

  @override
  State<AppFilter<M>> createState() => _AppSearchFilterState<T, M>();
}

class _AppSearchFilterState<T extends Object, M extends Object> extends _AppFilterState<M> {
  @override
  AppSearchFilter<T, M> get widget => super.widget as AppSearchFilter<T, M>;

  late final _itemNotifier = ValueNotifier<T?>(
    widget.initialValue,
  );

  late final _textController = TextEditingController(
    text: _formattedItem,
  );

  late final _overlayController = AppOverlayPortalController(
    onHide: _setValue,
  );

  final _searchNotifier = ValueNotifier<String>('');

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
    _searchNotifier.value = '';
  }

  void _setValue() {
    widget.onChanged(_itemNotifier.value);
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppTextFormField(
                            controller: _textController,
                            labelText: widget.label,
                            requestFocusOnInitState: true,
                            debounceTime: const Duration(milliseconds: 500),
                            onChanged: (value) => _searchNotifier.value = value,
                          ),
                          Flexible(
                            child: ValueListenableBuilder<String>(
                              valueListenable: _searchNotifier,
                              builder: (context, search, child) {
                                return FutureBuilder<List<T>>(
                                  key: ValueKey(search),
                                  future: widget.onSearch(search),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState != ConnectionState.done) {
                                      return const Padding(
                                        padding: EdgeInsets.all(kXXLSize),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    final items = snapshot.data!;

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: items.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final item = items[index];

                                        return ListTile(
                                          visualDensity: VisualDensity.compact,
                                          leading: widget.asAvatarUrl?.call(item) != null
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    widget.asAvatarUrl!.call(item)!,
                                                  ),
                                                )
                                              : null,
                                          title: Text(
                                            widget.asString?.call(item) ?? item.toString(),
                                          ),
                                          onTap: () {
                                            _itemNotifier.value = item;
                                            _setValue();
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
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
