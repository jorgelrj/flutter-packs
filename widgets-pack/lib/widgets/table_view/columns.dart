import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

class AppTableViewColumnBuilder<M extends Object> extends StatelessWidget {
  final TableColumn<M> column;
  final M item;

  const AppTableViewColumnBuilder({
    required this.column,
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return column.contentBuilder(
      context,
      item,
    );
  }
}
