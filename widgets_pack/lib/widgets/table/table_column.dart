import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widgets_pack/widgets/fields/fields.dart';
import 'package:widgets_pack/widgets/table/table.dart';

sealed class TableColumn<M extends Object> extends Equatable {
  final Widget label;
  final bool numeric;
  final double width;
  final bool fixed;
  final EdgeInsets contentPadding;
  final Decoration? decoration;
  final String nullValuePlaceholder;

  const TableColumn({
    required this.label,
    this.numeric = false,
    this.width = 350,
    this.fixed = false,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: kXSSize),
    this.decoration,
    this.nullValuePlaceholder = '-',
  });

  @override
  List<Object?> get props => [
        label,
        numeric,
        width,
        fixed,
        contentPadding,
        decoration,
        nullValuePlaceholder,
      ];

  Widget _builder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    throw UnimplementedError();
  }

  Widget labelBuilder(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.titleSmall!,
      child: Container(
        width: width,
        padding: contentPadding,
        decoration: decoration,
        child: Align(
          alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
          child: label,
        ),
      ),
    );
  }

  Widget contentBuilder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    return Container(
      width: width,
      padding: contentPadding,
      decoration: decoration,
      child: Align(
        alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: _builder(context, model, position, controller),
      ),
    );
  }
}

class TextColumn<M extends Object> extends TableColumn<M> {
  final String? Function(M model) value;
  final int? maxLines;

  const TextColumn({
    required super.label,
    required this.value,
    this.maxLines,
    super.numeric,
    super.width,
    super.fixed,
    super.contentPadding,
    super.decoration,
    super.nullValuePlaceholder,
  });

  @override
  Widget _builder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    final textValue = value(model);

    return TooltipVisibility(
      visible: textValue.isNotBlank,
      child: Tooltip(
        message: textValue ?? nullValuePlaceholder,
        child: Text(
          textValue ?? nullValuePlaceholder,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class NumberColumn<M extends Object> extends TableColumn<M> {
  final num? Function(M model) value;
  final String? Function(num)? format;

  const NumberColumn({
    required super.label,
    required this.value,
    super.width = 100,
    super.fixed,
    super.contentPadding,
    super.decoration,
    super.nullValuePlaceholder,
    this.format,
  }) : super(numeric: true);

  @override
  List<Object?> get props => [
        ...super.props,
        format,
        value,
      ];

  @override
  Widget _builder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    final numericValue = value(model);

    final stringValue = numericValue != null ? format?.call(numericValue) ?? numericValue.toString() : '-';

    return Text(stringValue);
  }
}

class WidgetColumn<M extends Object> extends TableColumn<M> {
  final Widget Function(M, TableController<M>) builder;

  const WidgetColumn({
    required super.label,
    required this.builder,
    super.numeric,
    super.width,
    super.fixed,
    super.contentPadding,
    super.decoration,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        builder,
      ];

  @override
  Widget _builder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    return builder(model, controller);
  }
}

class DateColumn<M extends Object> extends TableColumn<M> {
  final String dateFormat;
  final DateTime? Function(M model) value;

  const DateColumn({
    required this.value,
    required super.label,
    this.dateFormat = 'dd/MM/yyyy',
    super.width = 180,
    super.fixed,
    super.contentPadding,
    super.decoration,
    super.nullValuePlaceholder,
  }) : super(numeric: true);

  @override
  List<Object?> get props => [
        ...super.props,
        dateFormat,
        value,
      ];

  @override
  Widget _builder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    final date = value(model);

    return Text(
      date != null ? DateFormat(dateFormat).format(date) : nullValuePlaceholder,
    );
  }
}

class EditableTextColumn<M extends Object> extends TableColumn<M> {
  final String? Function(M model) value;
  final FutureOr<M?> Function(M model, String value) onChanged;

  const EditableTextColumn({
    required super.label,
    required this.value,
    required this.onChanged,
    super.width,
    super.contentPadding,
    super.decoration,
  });

  @override
  Widget _builder(
    BuildContext context,
    M model,
    ItemPosition position,
    TableController<M> controller,
  ) {
    final textValue = value(model);

    return AppTextFormField(
      border: InputBorder.none,
      style: context.textTheme.bodyMedium,
      debounceTime: const Duration(milliseconds: 500),
      initialValue: textValue,
      contentPadding: EdgeInsets.zero,
      showLoader: true,
      onChanged: (value) async {
        final newModel = await onChanged(model, value);

        if (newModel != null) {
          controller.replaceItemAt(
            position,
            newModel,
          );
        }
      },
    );
  }
}
