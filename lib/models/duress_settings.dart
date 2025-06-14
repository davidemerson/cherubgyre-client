class DuressSettings {
  final bool isEnabled;
  final bool isTestMode;
  final bool locationBasedEnabled;
  final bool accelerometerEnabled;
  final Duration? safetyTimerDuration;
  final double accelerometerThreshold;
  final int failedPinAttempts;

  DuressSettings({
    this.isEnabled = true,
    this.isTestMode = false,
    this.locationBasedEnabled = false,
    this.accelerometerEnabled = false,
    this.safetyTimerDuration,
    this.accelerometerThreshold = 20.0, // Default threshold for shock detection
    this.failedPinAttempts = 0,
  });

  factory DuressSettings.fromJson(Map<String, dynamic> json) {
    return DuressSettings(
      isEnabled: json['isEnabled'] as bool? ?? true,
      isTestMode: json['isTestMode'] as bool? ?? false,
      locationBasedEnabled: json['locationBasedEnabled'] as bool? ?? false,
      accelerometerEnabled: json['accelerometerEnabled'] as bool? ?? false,
      safetyTimerDuration: json['safetyTimerDuration'] != null
          ? Duration(minutes: json['safetyTimerDuration'] as int)
          : null,
      accelerometerThreshold: json['accelerometerThreshold'] as double? ?? 20.0,
      failedPinAttempts: json['failedPinAttempts'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'isTestMode': isTestMode,
      'locationBasedEnabled': locationBasedEnabled,
      'accelerometerEnabled': accelerometerEnabled,
      'safetyTimerDuration': safetyTimerDuration?.inMinutes,
      'accelerometerThreshold': accelerometerThreshold,
      'failedPinAttempts': failedPinAttempts,
    };
  }

  DuressSettings copyWith({
    bool? isEnabled,
    bool? isTestMode,
    bool? locationBasedEnabled,
    bool? accelerometerEnabled,
    Duration? safetyTimerDuration,
    double? accelerometerThreshold,
    int? failedPinAttempts,
  }) {
    return DuressSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      isTestMode: isTestMode ?? this.isTestMode,
      locationBasedEnabled: locationBasedEnabled ?? this.locationBasedEnabled,
      accelerometerEnabled: accelerometerEnabled ?? this.accelerometerEnabled,
      safetyTimerDuration: safetyTimerDuration ?? this.safetyTimerDuration,
      accelerometerThreshold: accelerometerThreshold ?? this.accelerometerThreshold,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
    );
  }
} 