import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';

enum _TextStyle {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelMedium,
  labelLarge,
  labelSmall,
}

sealed class _AppText extends Text {
  final _TextStyle textStyle;
  final Color? _color;
  final TextDecoration? _decoration;
  final FontWeight? _fontWeight;
  final double? _fontSize;

  const _AppText(
    super.data, {
    required this.textStyle,
    super.key,
    super.maxLines,
    super.overflow,
    super.softWrap,
    super.textAlign,
    Color? color,
    TextDecoration? decoration,
    FontWeight? fontWeight,
    double? fontSize,
  })  : _color = color,
        _decoration = decoration,
        _fontWeight = fontWeight,
        _fontSize = fontSize;

  _AppText copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  });

  _AppText color(Color? color) {
    return copyWith(
      color: color,
    );
  }

  _AppText decoration(TextDecoration? decoration) {
    return copyWith(
      decoration: decoration,
    );
  }

  _AppText align([TextAlign textAlign = TextAlign.center]) {
    return copyWith(
      textAlign: textAlign,
    );
  }

  _AppText size(double size) {
    return copyWith(
      fontSize: size,
    );
  }

  // Font weight 300
  _AppText light() {
    return copyWith(
      fontWeight: FontWeight.w300,
    );
  }

  /// Font weight 400
  _AppText normal() {
    return copyWith(
      fontWeight: FontWeight.w400,
    );
  }

  /// Font weight 500
  _AppText medium() {
    return copyWith(
      fontWeight: FontWeight.w500,
    );
  }

  /// Font weight 600
  _AppText semiBold() {
    return copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  /// Font weight 700
  _AppText bold() {
    return copyWith(
      fontWeight: FontWeight.w700,
    );
  }

  _AppText fontWeight(FontWeight? fontWeight) {
    return copyWith(
      fontWeight: fontWeight,
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final textTheme = context.textTheme;

    final textStyle = switch (this.textStyle) {
      (_TextStyle.labelMedium) => textTheme.labelMedium,
      (_TextStyle.labelLarge) => textTheme.labelLarge,
      (_TextStyle.bodySmall) => textTheme.bodySmall,
      (_TextStyle.bodyMedium) => textTheme.bodyMedium,
      (_TextStyle.bodyLarge) => textTheme.bodyLarge,
      (_TextStyle.titleSmall) => textTheme.titleSmall,
      (_TextStyle.titleMedium) => textTheme.titleMedium,
      (_TextStyle.titleLarge) => textTheme.titleLarge,
      (_TextStyle.headlineSmall) => textTheme.headlineSmall,
      (_TextStyle.headlineMedium) => textTheme.headlineMedium,
      (_TextStyle.headlineLarge) => textTheme.headlineLarge,
      (_TextStyle.displaySmall) => textTheme.displaySmall,
      (_TextStyle.displayLarge) => textTheme.displayLarge,
      (_TextStyle.displayMedium) => textTheme.displayMedium,
      (_TextStyle.labelSmall) => textTheme.labelSmall,
    };

    final effectiveStyle = TextStyle(
      color: _color,
      decoration: _decoration,
      fontWeight: _fontWeight,
      fontSize: _fontSize,
    );

    return textStyle?.merge(effectiveStyle) ?? effectiveStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      data!,
      style: _getTextStyle(context),
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class DisplayLarge extends _AppText {
  const DisplayLarge(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.displayLarge,
        );

  const DisplayLarge._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  DisplayLarge copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return DisplayLarge._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class DisplayMedium extends _AppText {
  const DisplayMedium(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.displayMedium,
        );

  const DisplayMedium._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  DisplayMedium copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return DisplayMedium._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class DisplaySmall extends _AppText {
  const DisplaySmall(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.displaySmall,
        );

  const DisplaySmall._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  DisplaySmall copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return DisplaySmall._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class TitleLarge extends _AppText {
  const TitleLarge(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.titleLarge,
        );

  const TitleLarge._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  TitleLarge copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return TitleLarge._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class BodyLarge extends _AppText {
  const BodyLarge(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.bodyLarge,
        );

  const BodyLarge._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  BodyLarge copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return BodyLarge._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class TitleSmall extends _AppText {
  const TitleSmall(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.titleSmall,
        );

  const TitleSmall._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  TitleSmall copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return TitleSmall._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class BodySmall extends _AppText {
  const BodySmall(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.bodySmall,
        );

  const BodySmall._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  BodySmall copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    double? fontSize,
    TextOverflow? overflow,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return BodySmall._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      fontSize: fontSize ?? _fontSize,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
    );
  }
}

class TitleMedium extends _AppText {
  const TitleMedium(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.titleMedium,
        );

  const TitleMedium._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  TitleMedium copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return TitleMedium._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class BodyMedium extends _AppText {
  const BodyMedium(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.bodyMedium,
        );

  const BodyMedium._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  BodyMedium copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return BodyMedium._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class HeadlineSmall extends _AppText {
  const HeadlineSmall(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.headlineSmall,
        );

  const HeadlineSmall._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  HeadlineSmall copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return HeadlineSmall._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class HeadlineMedium extends _AppText {
  const HeadlineMedium(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.headlineMedium,
        );

  const HeadlineMedium._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  HeadlineMedium copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return HeadlineMedium._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class HeadlineLarge extends _AppText {
  const HeadlineLarge(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.headlineLarge,
        );

  const HeadlineLarge._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  HeadlineLarge copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return HeadlineLarge._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class LabelSmall extends _AppText {
  const LabelSmall(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.labelSmall,
        );

  const LabelSmall._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  LabelSmall copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return LabelSmall._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class LabelMedium extends _AppText {
  const LabelMedium(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.labelMedium,
        );

  const LabelMedium._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  LabelMedium copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return LabelMedium._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}

class LabelLarge extends _AppText {
  const LabelLarge(
    super.data, {
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
  }) : super(
          textStyle: _TextStyle.labelLarge,
        );

  const LabelLarge._(
    super.data, {
    required super.textStyle,
    super.key,
    super.textAlign,
    super.softWrap,
    super.maxLines,
    super.overflow,
    super.color,
    super.decoration,
    super.fontWeight,
    super.fontSize,
  });

  @override
  LabelLarge copyWith({
    String? text,
    Color? color,
    TextAlign? textAlign,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
    double? fontSize,
    TextDecoration? decoration,
    FontWeight? fontWeight,
  }) {
    return LabelLarge._(
      text ?? data!,
      key: key,
      textStyle: textStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      color: color ?? _color,
      decoration: decoration ?? _decoration,
      fontWeight: fontWeight ?? _fontWeight,
      fontSize: fontSize ?? _fontSize,
    );
  }
}
