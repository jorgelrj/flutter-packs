import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppHoveringNotifier extends StatefulWidget {
  final ValueChanged<bool>? onHover;
  final Widget? child;
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext, bool, Widget?) builder;
  final Duration duration;
  final bool enabled;
  final bool forceHoveringOnMobile;

  const AppHoveringNotifier({
    required this.builder,
    this.onHover,
    this.child,
    this.duration = const Duration(milliseconds: 100),
    this.enabled = true,
    this.forceHoveringOnMobile = false,
    super.key,
  });

  @override
  State<AppHoveringNotifier> createState() => _AppHoveringNotifierState();
}

class _AppHoveringNotifierState extends State<AppHoveringNotifier> {
  late final _debouncer = Debouncer(duration: widget.duration);
  late final _hoveringNotifier = ValueNotifier(!kIsWeb && widget.forceHoveringOnMobile);

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
    _debouncer.dispose();
    _hoveringNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enabled || (widget.forceHoveringOnMobile && !kIsWeb)) {
          return;
        }

        _debouncer.dispose();
        _hoveringNotifier.value = true;
      },
      onExit: (_) {
        if (!widget.enabled || (widget.forceHoveringOnMobile && !kIsWeb)) {
          return;
        }

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
