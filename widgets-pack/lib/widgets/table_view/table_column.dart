import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

sealed class TableColumn<M extends Object> extends Equatable {
  final Widget label;
  final bool numeric;
  final double width;
  final EdgeInsets contentPadding;
  final Decoration? decoration;
  final String nullValuePlaceholder;

  const TableColumn({
    required this.label,
    this.numeric = false,
    this.width = 350,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: kXSSize),
    this.decoration,
    this.nullValuePlaceholder = '-',
  });

  @override
  List<Object?> get props => [
        label,
        numeric,
        width,
        contentPadding,
        decoration,
        nullValuePlaceholder,
      ];

  Widget _builder(
    BuildContext context,
    M model,
  ) {
    throw UnimplementedError();
  }

  Widget labelBuilder(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.titleSmall!,
      child: Container(
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
  ) {
    return Container(
      width: width,
      padding: contentPadding,
      decoration: decoration,
      child: Align(
        alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: _builder(context, model),
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
    super.contentPadding,
    super.decoration,
    super.nullValuePlaceholder,
  });

  @override
  Widget _builder(
    BuildContext context,
    M model,
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
  ) {
    final numericValue = value(model);

    final stringValue = numericValue != null ? format?.call(numericValue) ?? numericValue.toString() : '-';

    return Text(stringValue);
  }
}

class WidgetColumn<M extends Object> extends TableColumn<M> {
  final Widget Function(M) builder;

  const WidgetColumn({
    required super.label,
    required this.builder,
    super.numeric,
    super.width,
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
  ) {
    return builder(model);
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
  ) {
    final date = value(model);

    return Text(
      date != null ? DateFormat(dateFormat).format(date) : nullValuePlaceholder,
    );
  }
}
