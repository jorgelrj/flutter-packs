import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppChip extends StatelessWidget {
  final String label;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;
  final Color? backgroundColor;
  final Color? onBackgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Widget? avatar;
  final Widget? trailing;
  final MaterialStateProperty<Color?>? color;
  final MaterialStateProperty<Color?>? onColor;
  final IconData checkIcon;
  final Color? borderColor;

  const AppChip({
    required this.label,
    this.tooltip,
    this.onTap,
    this.onDelete,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.avatar,
    this.trailing,
    this.color,
    this.backgroundColor,
    this.onColor,
    this.onBackgroundColor,
    this.checkIcon = Icons.check,
    this.borderColor,
    super.key,
  });

  factory AppChip.secondary(
    BuildContext context, {
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AppChip(
      label: label,
      borderRadius: BorderRadius.circular(25),
      borderColor: Colors.transparent,
      backgroundColor: context.colorScheme.secondaryContainer,
      onBackgroundColor: context.colorScheme.onSecondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: kXSSize, vertical: kXXSSize),
      trailing: trailing,
      onTap: onTap,
    );
  }

  MaterialStateColor _defaultBackgroundColors(BuildContext context, ColorScheme scheme) {
    return MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return scheme.secondaryContainer;
      }

      return backgroundColor ?? context.wpColorsConfig.surfaceContainerHigh ?? scheme.surface;
    });
  }

  MaterialStateColor _defaultOnBackgroundColors(ColorScheme scheme) {
    return MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return scheme.onSecondaryContainer;
      }

      return onBackgroundColor ?? scheme.onSurfaceVariant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.colorScheme;

    return TooltipVisibility(
      visible: tooltip != null,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          hoverColor: Colors.transparent,
          child: AppHoveringNotifier(
            builder: (context, hovering, child) {
              final states = {
                if (selected) MaterialState.selected,
                if (hovering) MaterialState.hovered,
              };

              final effectiveBackgroundColor =
                  color?.resolve(states) ?? _defaultBackgroundColors(context, colorTheme).resolve(states);
              final effectiveOnBackgroundColor =
                  onColor?.resolve(states) ?? _defaultOnBackgroundColors(colorTheme).resolve(states);

              return Container(
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor,
                  border: Border.all(
                    color: selected ? effectiveBackgroundColor : borderColor ?? colorTheme.outline,
                  ),
                  borderRadius: borderRadius,
                ),
                padding: padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (selected)
                      Icon(
                        checkIcon,
                        size: 20,
                        color: effectiveOnBackgroundColor,
                      )
                    else if (avatar != null)
                      SizedBox.square(
                        dimension: 20,
                        child: avatar,
                      ),
                    Flexible(
                      child: LabelLarge(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).color(effectiveOnBackgroundColor),
                    ),
                    if (onDelete != null)
                      InkWell(
                        onTap: onDelete,
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: effectiveOnBackgroundColor,
                        ),
                      )
                    else if (trailing != null)
                      SizedBox.square(
                        dimension: 20,
                        child: FittedBox(child: trailing),
                      ),
                  ].addSpacingBetween(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
