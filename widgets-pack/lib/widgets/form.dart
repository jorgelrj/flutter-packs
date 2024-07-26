import 'package:flutter/material.dart';

class AppForm extends Form {
  const AppForm({
    required super.child,
    super.key,
  });

  @override
  FormState createState() => _AppFormState();

  static _AppFormState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppFormState>();
    assert(state != null, 'No AppFormState found in context');

    return state!;
  }
}

class _AppFormState extends FormState {
  final _validNotifier = ValueNotifier(false);

  @override
  bool validate() {
    final valid = super.validate();

    _validNotifier.value = valid;

    return valid;
  }

  @override
  void dispose() {
    _validNotifier.dispose();

    super.dispose();
  }
}

class AppFormStateBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool valid) builder;

  const AppFormStateBuilder({
    required this.builder,
    super.key,
  });

  @override
  State<AppFormStateBuilder> createState() => _AppFormStateBuilderState();
}

class _AppFormStateBuilderState extends State<AppFormStateBuilder> {
  late _AppFormState _formState;

  ValueNotifier<bool> get _validNotifier => _formState._validNotifier;

  @override
  void initState() {
    super.initState();

    _formState = AppForm.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _validNotifier,
      builder: (context, child) {
        return widget.builder(
          context,
          _validNotifier.value,
        );
      },
    );
  }
}
