import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';

class ScrollOverflowBuilder extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  const ScrollOverflowBuilder({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<ScrollOverflowBuilder> createState() => ScrollOverflowBuilderState();
}

class ScrollOverflowBuilderState extends State<ScrollOverflowBuilder> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Force rebuild to show overflow buttons
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final hasLeftOverflow = widget.controller.hasClients &&
            widget.controller.position.hasContentDimensions &&
            widget.controller.offset > 0;

        final hasRightOverflow = widget.controller.hasClients &&
            widget.controller.position.hasContentDimensions &&
            widget.controller.offset < widget.controller.position.maxScrollExtent;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            child!,
            if (hasRightOverflow)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        context.colorScheme.surface.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: const SizedBox(width: 20),
                ),
              ),
            if (hasLeftOverflow)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colorScheme.surface.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const SizedBox(width: 20),
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
