import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:widgets_pack/helpers/helpers.dart';
import 'package:widgets_pack/widgets/fields/text_field.dart';

part 'boolean.filter.dart';
part 'date.filter.dart';
part 'list.filter.dart';
part 'search.filter.dart';
part 'text.filter.dart';

sealed class AppFilter<M extends Object> extends StatefulWidget {
  const AppFilter({super.key});

  @override
  State<AppFilter<M>> createState();
}

sealed class _AppFilterState<M extends Object> extends State<AppFilter<M>> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
