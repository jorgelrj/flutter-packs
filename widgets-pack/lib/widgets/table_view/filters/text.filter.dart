part of 'filter.dart';

class AppTextFilter<M extends Object> extends AppFilter<M> {
  final String label;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextFilter({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.inputFormatters,
    super.key,
  });

  @override
  State<AppFilter<M>> createState() => _AppTextFilterState<M>();
}

class _AppTextFilterState<M extends Object> extends _AppFilterState<M> {
  @override
  AppTextFilter<M> get widget => super.widget as AppTextFilter<M>;

  late final _textController = TextEditingController(
    text: widget.initialValue ?? '',
  );

  final _overlayController = OverlayPortalController();

  final _link = LayerLink();

  final _focusNode = FocusNode();

  late String _valueOnOpen = _textController.text;

  void _focusNodeListener() {
    if (!_focusNode.hasFocus) {
      _setValue();
    }
  }

  void _setValue([bool force = false]) {
    final text = _textController.text;

    if (text == _valueOnOpen && !force) {
      return;
    }

    widget.onChanged(text);
    _overlayController.hide();

    AppTableView.maybeOf(context)?.controller.reload();
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(_focusNodeListener);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();

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
              child: SizedBox(
                width: 300,
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
                            onChanged: widget.onChanged,
                            labelText: widget.label,
                            focusNode: _focusNode,
                            requestFocusOnInitState: true,
                            inputFormatters: widget.inputFormatters,
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
          listenable: _textController,
          builder: (context, child) {
            final hasText = _textController.text.isNotEmpty;

            return FilterChip(
              label: Text(
                [
                  widget.label,
                  if (hasText) _textController.text,
                ].join(': '),
              ),
              selected: hasText,
              showCheckmark: false,
              deleteIconColor: context.colorScheme.onPrimary,
              onSelected: (_) {
                _valueOnOpen = _textController.text;
                _overlayController.show();
              },
              onDeleted: hasText
                  ? () {
                      _textController.clear();
                      _setValue(true);
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
