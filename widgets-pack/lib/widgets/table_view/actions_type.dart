enum TableActionsType {
  none,
  single,
  multi;

  bool get isMulti => this == TableActionsType.multi;
}
