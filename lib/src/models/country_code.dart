/// Represents a country's ISO code, display name, and international dialing code.
///
/// Optionally includes a path to a flag asset. This model is used throughout
/// the pickers and modal to render country identity and dial code.
class CountryCode {
  /// Human-readable country name, e.g. "Nepal".
  final String name;

  /// ISO 3166-1 alpha-2 country code, e.g. "NP".
  final String code;

  /// International telephone dialing prefix, e.g. "+977".
  final String dialCode;

  /// Optional flag asset path used for display.
  final String? flag;

  /// Creates a country descriptor.
  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    this.flag,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryCode &&
        other.name == name &&
        other.code == code &&
        other.dialCode == dialCode &&
        other.flag == flag;
  }

  @override
  int get hashCode {
    return name.hashCode ^ code.hashCode ^ dialCode.hashCode ^ flag.hashCode;
  }

  @override
  String toString() {
    return 'CountryCode(name: $name, code: $code, dialCode: $dialCode, flag: $flag)';
  }
}
