class TtsLocale {
  final String localeCode;
  final String? countryName;

  TtsLocale({
    required this.localeCode,
    this.countryName,
  });

  /// Returns the title of the locale. Include country name if available.
  String get title {
    if (countryName != null) {
      return '$countryName ($localeCode)';
    } else {
      return localeCode;
    }
  }

  @override
  String toString() {
    return 'TtsLocale{localeCode: $localeCode, countryName: $countryName}';
  }

  // when comparing equality, we can just compare the localeCode only
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TtsLocale && other.localeCode == localeCode;
  }

  @override
  int get hashCode => localeCode.hashCode;
}
