import 'dart:async';

import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

typedef AppSwitchLabels = ({String? left, String? right});

class AppSwitch extends StatefulWidget {
  final bool value;
  final FutureOr<bool?> Function(bool)? onChanged;
  final AppSwitchLabels? labels;

  const AppSwitch({
    this.value = false,
    this.onChanged,
    this.labels,
    super.key,
  });

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  late bool _value = widget.value;

  bool _loading = false;

  Future<void> _onChanged(bool value) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final shouldChange = await widget.onChanged!(value);

      setState(() {
        if (shouldChange != false) _value = value;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  void didUpdateWidget(covariant AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.labels?.left != null)
          BodyLarge(
            widget.labels!.left!,
          ).medium().color(!_value ? colorTheme.onSurface : colorTheme.onSurfaceVariant),
        Stack(
          children: [
            Switch(
              value: _value,
              onChanged: widget.onChanged == null ? null : _onChanged,
            ),
            if (_loading)
              Positioned(
                right: _value ? 12 : null,
                left: !_value ? 12 : null,
                top: 48 / 3,
                child: const AppCircularLoader(
                  size: 48 / 3,
                ),
              ),
          ],
        ),
        if (widget.labels?.right != null)
          BodyLarge(
            widget.labels!.right!,
          ).medium().color(_value ? colorTheme.onSurface : colorTheme.onSurfaceVariant),
      ].addSpacingBetween(),
    );
  }
}
