import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppTableFilterRow extends StatefulWidget {
  final AppButtonConfig? headerAction;
  final List<Widget> filters;

  const AppTableFilterRow({
    super.key,
    this.headerAction,
    this.filters = const [],
  });

  @override
  State<AppTableFilterRow> createState() => _AppTableFilterRowState();
}

class _AppTableFilterRowState extends State<AppTableFilterRow> {
  final scrollController = ScrollController();

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
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      color: context.colorScheme.surface,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListenableBuilder(
              listenable: scrollController,
              builder: (context, child) {
                final hasLeftOverflow = scrollController.hasClients &&
                    scrollController.position.hasContentDimensions &&
                    scrollController.offset > 0;

                final hasRightOverflow = scrollController.hasClients &&
                    scrollController.position.hasContentDimensions &&
                    scrollController.offset < scrollController.position.maxScrollExtent;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    child!,
                    if (hasRightOverflow)
                      Positioned(
                        height: 48,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                context.colorScheme.surface,
                                context.colorScheme.surface,
                                context.colorScheme.surface,
                              ],
                            ),
                          ),
                          child: AppButton.icon(
                            hoverColor: const Color(0xFF28292A),
                            onPressed: () {
                              scrollController.animateTo(
                                scrollController.offset + 100,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ),
                      ),
                    if (hasLeftOverflow)
                      Positioned(
                        height: 48,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colorScheme.surface,
                                context.colorScheme.surface,
                                context.colorScheme.surface,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: AppButton.icon(
                            hoverColor: const Color(0xFF28292A),
                            onPressed: () {
                              scrollController.animateTo(
                                scrollController.offset - 100,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                        ),
                      ),
                  ],
                );
              },
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: kXSRight,
                child: Row(
                  children: <Widget>[
                    if (widget.filters.isNotEmpty) ...widget.filters,
                  ].addSpacingBetween(),
                ),
              ),
            ),
          ),
          if (widget.headerAction != null) AppButton.fromConfig(widget.headerAction!),
        ].addSpacingBetween(),
      ),
    );
  }
}
