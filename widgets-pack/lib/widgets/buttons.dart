import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:widgets_pack/helpers/helpers.dart';

class AppButton extends StatefulWidget {
  final AppButtonType type;
  final Widget child;
  final Color? fillColor;
  final Color? hoverColor;
  final bool? loading;
  final Size? minimumSize;
  final EdgeInsets? padding;
  final ValueChanged<bool>? onHover;
  final FutureOrCallback? onPressed;
  final FutureOrCallback? onPressedDisabled;
  final bool showAnimation;

  const AppButton._({
    required this.type,
    required this.child,
    this.fillColor,
    this.hoverColor,
    this.loading,
    this.minimumSize,
    this.padding,
    this.onHover,
    this.onPressed,
    this.onPressedDisabled,
    this.showAnimation = true,
    super.key,
  });

  const AppButton.filled({
    required this.child,
    this.fillColor,
    this.hoverColor,
    this.loading,
    this.minimumSize,
    this.padding,
    this.onHover,
    this.onPressed,
    this.onPressedDisabled,
    this.showAnimation = true,
    super.key,
  }) : type = AppButtonType.filled;

  const AppButton.outlined({
    required this.child,
    this.fillColor,
    this.hoverColor,
    this.loading,
    this.minimumSize,
    this.padding,
    this.onHover,
    this.onPressed,
    this.onPressedDisabled,
    this.showAnimation = true,
    super.key,
  }) : type = AppButtonType.outlined;

  const AppButton.text({
    required this.child,
    this.fillColor,
    this.hoverColor,
    this.loading,
    this.minimumSize,
    this.padding,
    this.onHover,
    this.onPressed,
    this.onPressedDisabled,
    this.showAnimation = true,
    super.key,
  }) : type = AppButtonType.text;

  const AppButton.elevated({
    required this.child,
    this.fillColor,
    this.hoverColor,
    this.loading,
    this.minimumSize,
    this.padding,
    this.onHover,
    this.onPressed,
    this.onPressedDisabled,
    this.showAnimation = true,
    super.key,
  }) : type = AppButtonType.elevated;

  const AppButton.tonal({
    required this.child,
    this.fillColor,
    this.hoverColor,
    this.loading,
    this.minimumSize,
    this.padding,
    this.onHover,
    this.onPressed,
    this.onPressedDisabled,
    this.showAnimation = true,
    super.key,
  }) : type = AppButtonType.tonal;

  factory AppButton.icon({
    required Widget icon,
    Color? fillColor,
    bool? loading,
    EdgeInsets? padding,
    ValueChanged<bool>? onHover,
    FutureOrCallback? onPressed,
    FutureOrCallback? onPressedDisabled,
    String? tooltip,
    double size = 40,
    bool showAnimation = true,
    Key? key,
  }) {
    return _AppIconButton(
      key: key,
      fillColor: fillColor,
      loading: loading,
      padding: padding,
      onHover: onHover,
      onPressed: onPressed,
      onPressedDisabled: onPressedDisabled,
      tooltip: tooltip,
      size: size,
      showAnimation: showAnimation,
      child: icon,
    );
  }

  factory AppButton.fromConfig(AppButtonConfig config) {
    return switch (config.type) {
      (AppButtonType.filled) => AppButton.filled(
          onPressed: config.onPressed,
          onPressedDisabled: config.onPressedDisabled,
          child: config.child,
        ),
      (AppButtonType.elevated) => AppButton.elevated(
          onPressed: config.onPressed,
          onPressedDisabled: config.onPressedDisabled,
          child: config.child,
        ),
      (AppButtonType.tonal) => AppButton.tonal(
          onPressed: config.onPressed,
          onPressedDisabled: config.onPressedDisabled,
          child: config.child,
        ),
      (AppButtonType.outlined) => AppButton.outlined(
          onPressed: config.onPressed,
          onPressedDisabled: config.onPressedDisabled,
          child: config.child,
        ),
      (AppButtonType.text) => AppButton.text(
          onPressed: config.onPressed,
          onPressedDisabled: config.onPressedDisabled,
          child: config.child,
        ),
      (AppButtonType.icon) => _AppIconButton(
          onPressed: config.onPressed,
          onPressedDisabled: config.onPressedDisabled,
          child: config.child,
        ),
    };
  }

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  late final _loadingNotifier = ValueNotifier<bool>(
    widget.loading ?? false,
  );

  AppButtonType get _type => widget.type;

  FutureOrCallback? get _onPressed {
    if (widget.onPressed == null) {
      return null;
    }

    return () async {
      if (_loadingNotifier.value) {
        return;
      }

      _loadingNotifier.value = true;

      try {
        await widget.onPressed!();
      } catch (e) {
        rethrow;
      } finally {
        if (mounted) {
          _loadingNotifier.value = false;
        }
      }
    };
  }

  Widget get _loadingChild {
    return IntrinsicWidth(
      child: SpinKitThreeBounce(
        color: _type.isFilled ? context.colorScheme.onPrimary : context.colorScheme.primary,
        size: 16,
      ),
    );
  }

  Widget get _child {
    return ValueListenableBuilder<bool>(
      valueListenable: _loadingNotifier,
      builder: (context, isLoading, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: !widget.showAnimation || !isLoading,
              maintainAnimation: true,
              maintainState: true,
              maintainSize: true,
              child: child!,
            ),
            if (isLoading && widget.showAnimation) _loadingChild.sized(height: kXSSize),
          ],
        );
      },
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    if (widget.loading != oldWidget.loading) {
      _loadingNotifier.value = widget.loading ?? _loadingNotifier.value;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ButtonTheme.fromButtonThemeData(
      data: themeData.buttonTheme.copyWith(
        padding: widget.padding,
        hoverColor: widget.hoverColor,
      ),
      child: Builder(
        builder: (context) {
          final themeData = Theme.of(context);

          return GestureDetector(
            onTap: _onPressed == null && widget.onPressedDisabled != null ? widget.onPressedDisabled : null,
            child: switch (widget.type) {
              AppButtonType.tonal => FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: widget.padding,
                    backgroundColor: widget.fillColor,
                    minimumSize: widget.minimumSize,
                  ).merge(themeData.filledButtonTheme.style),
                  onHover: widget.onHover,
                  onPressed: _onPressed,
                  child: _child,
                ),
              AppButtonType.filled => FilledButton(
                  style: FilledButton.styleFrom(
                    padding: widget.padding,
                    backgroundColor: widget.fillColor,
                    minimumSize: widget.minimumSize,
                  ).merge(themeData.filledButtonTheme.style),
                  onHover: widget.onHover,
                  onPressed: _onPressed,
                  child: _child,
                ),
              AppButtonType.outlined => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: widget.padding,
                    minimumSize: widget.minimumSize,
                  ).merge(themeData.outlinedButtonTheme.style),
                  onHover: widget.onHover,
                  onPressed: _onPressed,
                  child: _child,
                ),
              AppButtonType.text => TextButton(
                  style: TextButton.styleFrom(
                    padding: widget.padding,
                    minimumSize: widget.minimumSize,
                    backgroundColor: widget.fillColor,
                  ).merge(themeData.textButtonTheme.style),
                  onHover: widget.onHover,
                  onPressed: _onPressed,
                  child: _child,
                ),
              AppButtonType.elevated => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: widget.padding,
                    backgroundColor: widget.fillColor,
                    minimumSize: widget.minimumSize,
                  ).merge(themeData.elevatedButtonTheme.style),
                  onHover: widget.onHover,
                  onPressed: _onPressed,
                  child: _child,
                ),
              AppButtonType.icon => throw UnimplementedError(),
            },
          );
        },
      ),
    );
  }
}

class _AppIconButton extends AppButton {
  final String? tooltip;
  final double size;

  const _AppIconButton({
    required super.child,
    super.padding,
    super.onPressed,
    super.onPressedDisabled,
    super.fillColor,
    super.loading,
    super.onHover,
    super.showAnimation,
    super.key,
    this.tooltip,
    this.size = 40,
  }) : super._(
          type: AppButtonType.icon,
        );

  @override
  State<AppButton> createState() => _AppIconsButtonState();
}

class _AppIconsButtonState extends _AppButtonState {
  @override
  _AppIconButton get widget => super.widget as _AppIconButton;

  @override
  Widget get _loadingChild {
    return IntrinsicWidth(
      child: SpinKitCircle(
        color: context.colorScheme.primary,
        size: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed == null && widget.onPressedDisabled != null ? widget.onPressedDisabled : null,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: widget.size, height: widget.size),
        child: IconButton(
          padding: EdgeInsets.zero,
          tooltip: widget.tooltip,
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: widget.fillColor ?? Colors.transparent,
            hoverColor: widget.hoverColor,
            shape: const CircleBorder(),
          ),
          onPressed: _onPressed,
          icon: _child,
        ),
      ),
    );
  }
}
