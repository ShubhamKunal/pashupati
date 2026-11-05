class SosRequest {
  final String id;
  final String caseNumber;
  final String reporterId;
  final String? reporterName;
  final String status; // OPEN, RESPONDING, HELP_ARRIVING, ASSISTANCE_PROVIDED, RESOLVED, CANCELLED, EXPIRED
  final String animalType; // DOG, CAT, CATTLE, BIRD, OTHER
  final String emergencyType; // INJURED, ROAD_ACCIDENT, TRAPPED, ABANDONED, SICK, IN_DANGER
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  final double? accuracyMeters;
  final String address;
  final String? landmark;
  final String? description;
  final String? primaryResponderId;
  final String? primaryResponderName;
  final String? primaryResponderPhone;
  final String? primaryResponderAvatar;
  final int? primaryResponderEtaMinutes;
  final List<SosMedia> media;
  final List<String> requirements;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SosRequest({
    required this.id,
    required this.caseNumber,
    required this.reporterId,
    this.reporterName,
    required this.status,
    required this.animalType,
    required this.emergencyType,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.accuracyMeters,
    required this.address,
    this.landmark,
    this.description,
    this.primaryResponderId,
    this.primaryResponderName,
    this.primaryResponderPhone,
    this.primaryResponderAvatar,
    this.primaryResponderEtaMinutes,
    this.media = const [],
    this.requirements = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory SosRequest.fromJson(Map<String, dynamic> json) {
    return SosRequest(
      id: json['id'] as String? ?? '',
      caseNumber: json['case_number'] as String? ?? 'SOS-BLR-0000',
      reporterId: json['reporter_id'] as String? ?? '',
      reporterName: json['reporter_name'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      animalType: json['animal_type'] as String? ?? 'DOG',
      emergencyType: json['emergency_type'] as String? ?? 'INJURED',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      accuracyMeters: (json['accuracy_meters'] as num?)?.toDouble(),
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String?,
      description: json['description'] as String?,
      primaryResponderId: json['primary_responder_id'] as String?,
      primaryResponderName: json['primary_responder_name'] as String?,
      primaryResponderPhone: json['primary_responder_phone'] as String?,
      primaryResponderAvatar: json['primary_responder_avatar'] as String?,
      primaryResponderEtaMinutes: json['primary_responder_eta_minutes'] as int?,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => SosMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'case_number': caseNumber,
    'reporter_id': reporterId,
    'reporter_name': reporterName,
    'status': status,
    'animal_type': animalType,
    'emergency_type': emergencyType,
    'latitude': latitude,
    'longitude': longitude,
    'distance_meters': distanceMeters,
    'accuracy_meters': accuracyMeters,
    'address': address,
    'landmark': landmark,
    'description': description,
    'primary_responder_id': primaryResponderId,
    'primary_responder_name': primaryResponderName,
    'primary_responder_phone': primaryResponderPhone,
    'primary_responder_avatar': primaryResponderAvatar,
    'primary_responder_eta_minutes': primaryResponderEtaMinutes,
    'media': media.map((e) => e.toJson()).toList(),
    'requirements': requirements,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String get formattedDistance {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()}m away';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km away';
  }

  bool get isActive => status == 'OPEN' || status == 'RESPONDING' || status == 'HELP_ARRIVING';
}

class SosMedia {
  final String id;
  final String mediaType; // IMAGE, AUDIO_NOTE, VIDEO
  final String url;
  final String? thumbnailUrl;
  final String? caption;

  const SosMedia({
    required this.id,
    required this.mediaType,
    required this.url,
    this.thumbnailUrl,
    this.caption,
  });

  factory SosMedia.fromJson(Map<String, dynamic> json) {
    return SosMedia(
      id: json['id'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'IMAGE',
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'media_type': mediaType,
    'url': url,
    'thumbnail_url': thumbnailUrl,
    'caption': caption,
  };
}

class SosStatusHistory {
  final String id;
  final String? previousStatus;
  final String newStatus;
  final String actorId;
  final String? actorName;
  final String? reason;
  final DateTime createdAt;

  const SosStatusHistory({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    required this.actorId,
    this.actorName,
    this.reason,
    required this.createdAt,
  });

  factory SosStatusHistory.fromJson(Map<String, dynamic> json) {
    return SosStatusHistory(
      id: json['id'] as String? ?? '',
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String? ?? 'OPEN',
      actorId: json['actor_id'] as String? ?? '',
      actorName: json['actor_name'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SosDetail {
  final SosRequest sos;
  final List<SosStatusHistory> statusHistory;
  final int activeRespondersCount;

  const SosDetail({
    required this.sos,
    this.statusHistory = const [],
    this.activeRespondersCount = 0,
  });

  factory SosDetail.fromJson(Map<String, dynamic> json) {
    return SosDetail(
      sos: SosRequest.fromJson(json['sos'] as Map<String, dynamic>),
      statusHistory: (json['status_history'] as List<dynamic>?)
              ?.map((e) => SosStatusHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeRespondersCount: json['active_responders_count'] as int? ?? 0,
    );
  }
}

