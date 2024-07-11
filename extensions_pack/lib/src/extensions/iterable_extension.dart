import 'package:extensions_pack/extensions_pack.dart';

extension NullIterableExtension<T> on Iterable<T>? {
  bool get isBlank => this == null || this!.isEmpty;
  bool get isNotBlank => !isBlank;

  T? get firstOrNull => isBlank ? null : this!.first;
  T? get lastOrNull => isBlank ? null : this!.last;

  int count() => isBlank ? 0 : this!.length;

  int countWhere(bool Function(T) condition) {
    int count = 0;
    if (this.count() == 0) return count;
    for (final item in this!) if (condition(item)) count++;
    return count;
  }

  Iterable<List<T>> chunked(int chunkSize) sync* {
    if (isBlank) {
      yield [];
      return;
    }
    int skip = 0;
    while (skip < this!.length) {
      final chunk = this!.skip(skip).take(chunkSize);
      yield chunk.toList(growable: false);
      skip += chunkSize;
      if (chunk.length < chunkSize) return;
    }
  }
}

extension IterableEPExtension<T> on Iterable<T?> {
  Iterable<T> whereTruthy() {
    final values = where((e) => e.truthy);

    return values.cast<T>();
  }
}
