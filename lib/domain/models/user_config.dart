class UserConfig {
  final bool hasPin;
  final bool useBiometrics;
  final bool autoLockEnabled;
  final int autoLockMinutes;

  const UserConfig({
    required this.hasPin,
    required this.useBiometrics,
    this.autoLockEnabled = false,
    this.autoLockMinutes = 5,
  });

  /// Factory constructor to create a UserConfig from data
  factory UserConfig.fromMap(Map<String, dynamic> map) {
    return UserConfig(
      hasPin: map['has_pin'] ?? false,
      useBiometrics: map['use_biometrics'] ?? false,
      autoLockEnabled: map['auto_lock_enabled'] ?? false,
      autoLockMinutes: map['auto_lock_minutes'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'has_pin': hasPin,
      'use_biometrics': useBiometrics,
      'auto_lock_enabled': autoLockEnabled,
      'auto_lock_minutes': autoLockMinutes,
    };
  }

  UserConfig copyWith({
    bool? hasPin,
    bool? useBiometrics,
    bool? autoLockEnabled,
    int? autoLockMinutes,
  }) {
    return UserConfig(
      hasPin: hasPin ?? this.hasPin,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    );
  }

  @override
  String toString() {
    return 'UserConfig(hasPin: $hasPin, useBiometrics: $useBiometrics, '
        'autoLockEnabled: $autoLockEnabled, autoLockMinutes: $autoLockMinutes)';
  }
}
