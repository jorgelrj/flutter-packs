import 'package:flutter/material.dart';

class ListenableSelectorBuilder extends StatefulWidget {
  const ListenableSelectorBuilder({super.key});

  @override
  State<ListenableSelectorBuilder> createState() => _ListenableSelectorBuilderState();
}

class _ListenableSelectorBuilderState extends State<ListenableSelectorBuilder> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: builder,
    );
  }
}
