import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';

class AppHoveringNotifier extends StatefulWidget {
  final ValueChanged<bool>? onHover;
  final Widget? child;
  final Widget Function(BuildContext, bool, Widget?) builder;
  final Duration duration;
  final bool enabled;

  const AppHoveringNotifier({
    required this.builder,
    this.onHover,
    this.child,
    this.duration = const Duration(milliseconds: 100),
    this.enabled = true,
    super.key,
  });

  @override
  State<AppHoveringNotifier> createState() => _AppHoveringNotifierState();
}

class _AppHoveringNotifierState extends State<AppHoveringNotifier> {
  late final _debouncer = Debouncer(duration: widget.duration);
  late final _hoveringNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _hoveringNotifier.addListener(() {
      widget.onHover?.call(_hoveringNotifier.value);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!widget.enabled) {
      _hoveringNotifier.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();

    _debouncer.dispose();
    _hoveringNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enabled) return;

        _debouncer.dispose();
        _hoveringNotifier.value = true;
      },
      onExit: (_) {
        if (!widget.enabled) return;

        _debouncer.run(() => _hoveringNotifier.value = false);
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _hoveringNotifier,
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}
