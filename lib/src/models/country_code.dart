class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String? flag;

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
    return name.hashCode ^
        code.hashCode ^
        dialCode.hashCode ^
        flag.hashCode;
  }

  @override
  String toString() {
    return 'CountryCode(name: $name, code: $code, dialCode: $dialCode, flag: $flag)';
  }
}
