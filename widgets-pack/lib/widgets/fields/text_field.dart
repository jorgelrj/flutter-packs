import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:widgets_pack/widgets/widgets.dart';

enum AppTextFormFieldLabelBehavior {
  above,
  flutterAuto,
  flutterAlways;

  bool get isFlutter => name.contains('flutter');

  FloatingLabelBehavior? flutterBehavior() {
    return switch (this) {
      (AppTextFormFieldLabelBehavior.flutterAuto) => FloatingLabelBehavior.auto,
      (AppTextFormFieldLabelBehavior.flutterAlways) => FloatingLabelBehavior.always,
      (_) => null,
    };
  }
}

enum AppTextFormFieldErrorType {
  iconRight,
  iconLeft,
  none,
  string,
}

class AppTextFormField extends StatefulWidget {
  static String tapRegionGroupId = 'AppTextFieldGroupId';

  final List<String>? autofillHints;
  final AutovalidateMode autoValidateMode;
  final InputBorder? border;
  final BoxConstraints? constraints;
  final EdgeInsets? contentPadding;
  final TextEditingController? controller;
  final Duration debounceTime;
  final InputBorder? disabledBorder;
  final bool enabled;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final AppTextFormFieldErrorType errorType;
  final Color? fillColor;
  final bool? filled;
  final InputBorder? focusedBorder;
  final FocusNode? focusNode;
  final String? helperText;
  final String? hintText;
  final TextStyle? hintStyle;
  final Color? hoverColor;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecorationTheme? inputTheme;
  final bool? isCollapsed;
  final TextInputType? keyboardType;
  final AppTextFormFieldLabelBehavior labelBehavior;
  final String? labelText;
  final TextStyle? labelStyle;
  final Widget? label;
  final bool loseFocusOnOutsideTap;
  final int? maxLength;

  /// Value is ignored if [obscureText] is true
  final int? maxLines;

  final int? minLines;
  final bool obscureText;
  final FutureOr<void> Function(String value)? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final Widget? prefix;
  final Widget? prefixIcon;
  final String? prefixText;
  final bool readOnly;
  final bool requestFocusOnInitState;
  final ScrollPhysics? scrollPhysics;
  final bool selectAllOnFocus;
  final bool showLoader;
  final TextStyle? style;

  /// Value is ignored if [obscureText] is true
  final Widget? suffixIcon;

  final Widget? suffix;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;

  const AppTextFormField({
    this.autofillHints,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.border,
    this.constraints,
    this.contentPadding,
    this.controller,
    this.debounceTime = Duration.zero,
    this.disabledBorder,
    this.enabled = true,
    this.enabledBorder,
    this.errorBorder,
    this.errorType = AppTextFormFieldErrorType.string,
    this.fillColor,
    this.filled,
    this.focusedBorder,
    this.focusNode,
    this.helperText,
    this.hintText,
    this.hintStyle,
    this.hoverColor,
    this.initialValue,
    this.inputFormatters,
    this.inputTheme,
    this.isCollapsed,
    this.keyboardType,
    this.labelBehavior = AppTextFormFieldLabelBehavior.flutterAuto,
    this.labelText,
    this.labelStyle,
    this.label,
    this.loseFocusOnOutsideTap = true,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.onFocusChanged,
    this.prefix,
    this.prefixIcon,
    this.prefixText,
    this.readOnly = false,
    this.requestFocusOnInitState = false,
    this.scrollPhysics,
    this.selectAllOnFocus = false,
    this.showLoader = false,
    this.style,
    this.suffix,
    this.suffixIcon,
    this.suffixText,
    this.suffixStyle,
    this.textAlign = TextAlign.start,
    this.textInputAction,
    this.validator,
    this.onTap,
    super.key,
  });

  AppTextFormField.search({
    this.border,
    this.constraints,
    this.contentPadding,
    this.controller,
    this.disabledBorder,
    this.enabled = true,
    this.fillColor,
    this.filled,
    this.focusedBorder,
    this.focusNode,
    this.helperText,
    this.hintText = 'Search',
    this.hoverColor,
    this.initialValue,
    this.inputTheme,
    this.isCollapsed,
    this.labelText,
    this.labelStyle,
    this.label,
    this.loseFocusOnOutsideTap = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.onFocusChanged,
    this.readOnly = false,
    this.requestFocusOnInitState = false,
    this.scrollPhysics,
    this.selectAllOnFocus = false,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    super.key,
  })  : autofillHints = null,
        autoValidateMode = AutovalidateMode.disabled,
        debounceTime = defaultDebounceTime,
        enabledBorder = null,
        errorBorder = null,
        errorType = AppTextFormFieldErrorType.string,
        hintStyle = null,
        inputFormatters = null,
        keyboardType = TextInputType.text,
        labelBehavior = AppTextFormFieldLabelBehavior.flutterAuto,
        maxLength = null,
        maxLines = 1,
        minLines = null,
        obscureText = false,
        prefix = null,
        prefixIcon = const Icon(
          Icons.search,
          size: kMDSize,
        ),
        prefixText = null,
        showLoader = false,
        style = null,
        suffix = null,
        suffixText = null,
        suffixStyle = null,
        textInputAction = TextInputAction.search,
        validator = null,
        onTap = null;

  static Duration get defaultDebounceTime => const Duration(milliseconds: 350);

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  final _debounceSearch = BehaviorSubject<String>();
  final _inputKey = GlobalKey<FormFieldState<String>>();

  late final _configNotifier = ValueNotifier(
    _AppTextFormFieldConfig(
      loading: false,
      obscureText: widget.obscureText,
      error: null,
    ),
  );
  late final _focusNode = widget.focusNode ?? FocusNode();
  late final _controller = widget.controller ?? TextEditingController();

  String? _validator(String? value) {
    final error = widget.validator?.call(value);
    _configNotifier.value = _configNotifier.value.copyWith(error: () => error);

    return error;
  }

  void _focusListener() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);

    if (_focusNode.hasFocus && widget.selectAllOnFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(_focusListener);

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _debounceSearch.distinct().debounceTime(widget.debounceTime).listen((event) async {
      if (widget.showLoader) {
        _configNotifier.value = _configNotifier.value.copyWith(loading: true);
      }

      await widget.onChanged?.call(_controller.text);

      if (widget.showLoader) {
        _configNotifier.value = _configNotifier.value.copyWith(loading: false);
      }
    });

    if (widget.requestFocusOnInitState) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialValue ?? '';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _focusNode.removeListener(_focusListener);

    _debounceSearch.close();
    _configNotifier.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = widget.inputTheme ?? Theme.of(context).inputDecorationTheme;

    return TapRegion(
      groupId: AppTextFormField.tapRegionGroupId,
      child: ValueListenableBuilder<_AppTextFormFieldConfig>(
        valueListenable: _configNotifier,
        builder: (context, config, child) {
          final loading = config.loading;
          final hasError = config.hasError;
          final obscureText = config.obscureText;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.labelText != null && !widget.labelBehavior.isFlutter) ...[
                TitleMedium(widget.labelText!),
                const Spacing(mainAxisExtent: kXXSSize),
              ],
              TextFormField(
                key: _inputKey,
                onTap: widget.onTap,
                autofillHints: widget.autofillHints,
                autovalidateMode: widget.autoValidateMode,
                controller: _controller,
                enabled: widget.enabled,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.minLines,
                onChanged: _debounceSearch.add,
                obscureText: config.obscureText,
                onTapOutside: widget.loseFocusOnOutsideTap ? (_) => _focusNode.unfocus() : null,
                validator: widget.validator != null ? _validator : null,
                style: widget.style ?? Theme.of(context).textTheme.bodyLarge,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                onFieldSubmitted: widget.onFieldSubmitted,
                scrollPhysics: widget.scrollPhysics,
                textInputAction: widget.textInputAction,
                maxLength: widget.maxLength,
                textAlign: widget.textAlign,
                decoration: InputDecoration(
                  hoverColor: widget.hoverColor,
                  constraints: widget.constraints,
                  contentPadding: widget.contentPadding,
                  errorStyle: widget.errorType == AppTextFormFieldErrorType.string
                      ? null
                      : const TextStyle(
                          fontSize: 0,
                        ),
                  disabledBorder: widget.disabledBorder ?? widget.border,
                  enabledBorder: widget.enabledBorder ?? widget.border,
                  errorBorder: widget.errorBorder ?? widget.border,
                  focusedErrorBorder: widget.errorBorder ?? widget.border,
                  labelStyle: widget.labelStyle,
                  floatingLabelStyle: widget.labelStyle,
                  helperText: widget.helperText,
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle,
                  isCollapsed: widget.isCollapsed,
                  prefix: widget.prefix,
                  prefixIcon: hasError && widget.errorType == AppTextFormFieldErrorType.iconLeft
                      ? Tooltip(
                          message: config.error,
                          child: Icon(
                            Icons.error,
                            color: context.colorScheme.error,
                          ),
                        )
                      : widget.prefixIcon,
                  prefixText: widget.prefixText,
                  suffixText: widget.suffixText,
                  suffixStyle: widget.suffixStyle,
                  focusedBorder: widget.focusedBorder ?? widget.border,
                  fillColor: widget.fillColor,
                  filled: widget.filled,
                  labelText: widget.labelBehavior.isFlutter ? widget.labelText : null,
                  label: widget.label,
                  floatingLabelBehavior: widget.labelBehavior.flutterBehavior(),
                  suffixIcon: hasError && widget.errorType == AppTextFormFieldErrorType.iconRight
                      ? Tooltip(
                          message: config.error,
                          child: Icon(
                            Icons.error,
                            color: context.colorScheme.error,
                          ),
                        )
                      : widget.obscureText
                          ? GestureDetector(
                              onTap: () {
                                _configNotifier.value = _configNotifier.value.copyWith(
                                  obscureText: !obscureText,
                                );
                              },
                              child: Icon(
                                obscureText ? Icons.visibility : Icons.visibility_off,
                              ),
                            )
                          : widget.suffixIcon,
                  suffix: widget.suffix,
                ).applyDefaults(inputTheme),
              ),
              if (loading) const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }
}

class _AppTextFormFieldConfig extends Equatable {
  final bool loading;
  final bool obscureText;
  final String? error;

  const _AppTextFormFieldConfig({
    required this.loading,
    required this.obscureText,
    required this.error,
  });

  @override
  List<Object?> get props => [loading, obscureText, error];

  bool get hasError => error != null;

  _AppTextFormFieldConfig copyWith({
    bool? loading,
    bool? obscureText,
    String? Function()? error,
  }) {
    return _AppTextFormFieldConfig(
      loading: loading ?? this.loading,
      obscureText: obscureText ?? this.obscureText,
      error: error != null ? error() : this.error,
    );
  }
}
