class Organization {
  final String id;
  final String name;
  final String orgType; // VET_HOSPITAL, NGO, SHELTER
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  final String phone;
  final String? emergencyPhone;
  final String? website;
  final String? operatingHours;
  final bool is247;
  final bool isVerified;
  final List<String> facilities;

  const Organization({
    required this.id,
    required this.name,
    required this.orgType,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    required this.phone,
    this.emergencyPhone,
    this.website,
    this.operatingHours,
    this.is247 = false,
    this.isVerified = false,
    this.facilities = const [],
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      orgType: json['org_type'] as String? ?? 'NGO',
      description: json['description'] as String?,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      phone: json['phone'] as String? ?? '',
      emergencyPhone: json['emergency_phone'] as String?,
      website: json['website'] as String?,
      operatingHours: json['operating_hours'] as String?,
      is247: json['is_24_7'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get formattedDistance {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()}m away';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km away';
  }
}

