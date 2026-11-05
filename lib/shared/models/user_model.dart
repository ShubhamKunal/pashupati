class UserModel {
  final String id;
  final String phone;
  final String name;
  final String? avatarUrl;
  final String role;
  final String preferredLanguage;
  final VolunteerProfile? volunteerProfile;

  const UserModel({
    required this.id,
    required this.phone,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.preferredLanguage = 'en',
    this.volunteerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? 'Rescuer',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'VOLUNTEER',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      volunteerProfile: json['volunteer_profile'] != null
          ? VolunteerProfile.fromJson(json['volunteer_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'name': name,
    'avatar_url': avatarUrl,
    'role': role,
    'preferred_language': preferredLanguage,
    'volunteer_profile': volunteerProfile?.toJson(),
  };

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? avatarUrl,
    String? role,
    String? preferredLanguage,
    VolunteerProfile? volunteerProfile,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      volunteerProfile: volunteerProfile ?? this.volunteerProfile,
    );
  }
}

class VolunteerProfile {
  final bool isAvailable;
  final String verificationStatus;
  final String? vehicleType;
  final List<String> capabilities;
  final int responseRadiusKm;
  final int rescuesCompletedCount;
  final String? badgeLabel;

  const VolunteerProfile({
    this.isAvailable = true,
    this.verificationStatus = 'VERIFIED',
    this.vehicleType = 'TWO_WHEELER',
    this.capabilities = const ['FIRST_AID', 'TRANSPORT', 'PHYSICAL_AID'],
    this.responseRadiusKm = 5,
    this.rescuesCompletedCount = 0,
    this.badgeLabel = 'Verified First Responder',
  });

  factory VolunteerProfile.fromJson(Map<String, dynamic> json) {
    return VolunteerProfile(
      isAvailable: json['is_available'] as bool? ?? true,
      verificationStatus: json['verification_status'] as String? ?? 'VERIFIED',
      vehicleType: json['vehicle_type'] as String? ?? 'TWO_WHEELER',
      capabilities: (json['capabilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      responseRadiusKm: json['response_radius_km'] as int? ?? 5,
      rescuesCompletedCount: json['rescues_completed_count'] as int? ?? 0,
      badgeLabel: json['badge_label'] as String? ?? 'Verified First Responder',
    );
  }

  Map<String, dynamic> toJson() => {
    'is_available': isAvailable,
    'verification_status': verificationStatus,
    'vehicle_type': vehicleType,
    'capabilities': capabilities,
    'response_radius_km': responseRadiusKm,
    'rescues_completed_count': rescuesCompletedCount,
    'badge_label': badgeLabel,
  };
}

