class UserConfig {
  final bool hasPin;
  final bool useBiometrics;

  const UserConfig({
    required this.hasPin,
    required this.useBiometrics,
  });

  /// Factory constructor to create a UserConfig from data
  factory UserConfig.fromMap(Map<String, dynamic> map) {
    return UserConfig(
      hasPin: map['has_pin'] ?? false,
      useBiometrics: map['use_biometrics'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'has_pin': hasPin,
      'use_biometrics': useBiometrics,
    };
  }

  UserConfig copyWith({
    bool? hasPin,
    bool? useBiometrics,
  }) {
    return UserConfig(
      hasPin: hasPin ?? this.hasPin,
      useBiometrics: useBiometrics ?? this.useBiometrics,
    );
  }

  @override
  String toString() {
    return 'UserConfig(hasPin: $hasPin, useBiometrics: $useBiometrics)';
  }
}
