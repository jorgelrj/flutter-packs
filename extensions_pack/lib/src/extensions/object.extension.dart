extension ObjectsEPExtension on Object? {
  bool get truthy {
    if (this == null) return false;
    if (this is bool) return this as bool;
    if (this is String) return (this as String).isNotEmpty;
    if (this is List) return (this as List).isNotEmpty;
    if (this is Map) return (this as Map).isNotEmpty;
    if (this is Set) return (this as Set).isNotEmpty;
    if (this is num) return (this as num) != 0;

    return true;
  }
}
