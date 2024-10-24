extension ObjectsEPExtension on Object? {
  bool get truthy {
    return switch (this) {
      final bool value => value,
      final String value when value == 'false' => false,
      final String value when value == '0' => false,
      final String value => value.isNotEmpty,
      final List value => value.isNotEmpty,
      final Map value => value.isNotEmpty,
      final Set value => value.isNotEmpty,
      final num value => value != 0,
      _ => false,
    };
  }
}
