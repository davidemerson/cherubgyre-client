class LocationData {
  final String uid;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isInDuress;
  final bool isTestMode;

  LocationData({
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isInDuress = false,
    this.isTestMode = false,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      uid: json['uid'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isInDuress: json['isInDuress'] as bool? ?? false,
      isTestMode: json['isTestMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'isInDuress': isInDuress,
      'isTestMode': isTestMode,
    };
  }
} 