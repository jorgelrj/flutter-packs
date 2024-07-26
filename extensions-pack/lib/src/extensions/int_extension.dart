extension IntEPExtension on int {
  Duration asDays() => Duration(days: this);
  Duration asHours() => Duration(hours: this);
  Duration asMinutes() => Duration(minutes: this);
  Duration asSeconds() => Duration(seconds: this);
  Duration asMilliseconds() => Duration(milliseconds: this);

  int nextMultipleOf(int multiplier) {
    if (multiplier <= 0) {
      throw ArgumentError('Multiplier cannot be zero');
    }

    final remainder = this % multiplier;

    if (remainder == 0) {
      return this;
    } else {
      return this + (multiplier - remainder);
    }
  }
}
