import 'package:flutter/material.dart';

class AppOverlayBuilder extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, OverlayPortalController controller) overlayBuilder;
  final BoxConstraints overlayConstraints;
  final Object? overlayGroupId;
  final Alignment alignment;
  final Offset offset;

  const AppOverlayBuilder({
    required this.child,
    required this.overlayBuilder,
    required this.overlayConstraints,
    this.overlayGroupId,
    this.alignment = Alignment.bottomLeft,
    this.offset = Offset.zero,
    super.key,
  });

  @override
  State<AppOverlayBuilder> createState() => _AppOverlayBuilderState();
}

class _AppOverlayBuilderState extends State<AppOverlayBuilder> {
  final _chipKey = GlobalKey<_AppOverlayBuilderState>();

  final _overlayController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _chipKey,
      onTap: _overlayController.toggle,
      child: OverlayPortal.targetsRootOverlay(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          final renderBox = _chipKey.currentContext?.findRenderObject() as RenderBox;
          final boxPosition = renderBox.localToGlobal(Offset.zero);
          final size = MediaQuery.of(context).size;

          double leftPosition = boxPosition.dx + renderBox.size.width * widget.alignment.x + widget.offset.dx;
          if (leftPosition + widget.overlayConstraints.maxWidth > size.width) {
            leftPosition = size.width - widget.overlayConstraints.maxWidth;
          }

          double topPosition = boxPosition.dy + renderBox.size.height * widget.alignment.y + widget.offset.dy;
          if (topPosition + widget.overlayConstraints.maxHeight > size.height) {
            topPosition = size.height - widget.overlayConstraints.maxHeight;
          }

          return Positioned(
            left: leftPosition,
            top: topPosition,
            child: ConstrainedBox(
              constraints: widget.overlayConstraints,
              child: TapRegion(
                groupId: widget.overlayGroupId,
                onTapOutside: (_) => _overlayController.hide(),
                child: widget.overlayBuilder(context, _overlayController),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
