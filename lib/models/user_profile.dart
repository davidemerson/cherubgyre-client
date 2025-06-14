class UserProfile {
  final String uid;
  final String username;
  final String avatarUrl;
  final bool isInDuress;
  final DateTime lastCheckIn;
  final bool isActive;
  final List<String> followers;
  final List<String> following;
  final bool locationBasedDuressEnabled;
  final bool accelerometerDuressEnabled;

  UserProfile({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    this.isInDuress = false,
    required this.lastCheckIn,
    this.isActive = true,
    this.followers = const [],
    this.following = const [],
    this.locationBasedDuressEnabled = false,
    this.accelerometerDuressEnabled = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      isInDuress: json['isInDuress'] as bool? ?? false,
      lastCheckIn: DateTime.parse(json['lastCheckIn'] as String),
      isActive: json['isActive'] as bool? ?? true,
      followers: List<String>.from(json['followers'] as List? ?? []),
      following: List<String>.from(json['following'] as List? ?? []),
      locationBasedDuressEnabled: json['locationBasedDuressEnabled'] as bool? ?? false,
      accelerometerDuressEnabled: json['accelerometerDuressEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'avatarUrl': avatarUrl,
      'isInDuress': isInDuress,
      'lastCheckIn': lastCheckIn.toIso8601String(),
      'isActive': isActive,
      'followers': followers,
      'following': following,
      'locationBasedDuressEnabled': locationBasedDuressEnabled,
      'accelerometerDuressEnabled': accelerometerDuressEnabled,
    };
  }
} 