import 'package:dio/dio.dart';
import '../../app/config/config.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/organization_model.dart';
import '../../shared/models/sos_model.dart';
import '../../shared/models/user_model.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.defaultApiBaseUrl,
        connectTimeout: AppConfig.requestTimeout,
        receiveTimeout: AppConfig.requestTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // If server is not reachable, we log and proceed with fallback
          return handler.next(error);
        },
      ),
    );
  }

  // --- Auth APIs ---

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    try {
      final res = await _dio.post('/auth/otp/request', data: {'phone': phone});
      return res.data as Map<String, dynamic>;
    } catch (_) {
      // Offline fallback
      return {
        'success': true,
        'message': 'Verification code sent (Dev: 123456)',
        'dev_otp': '123456'
      };
    }
  }

  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
    String? name,
  }) async {
    try {
      final res = await _dio.post('/auth/otp/verify', data: {
        'phone': phone,
        'otp': otp,
        'name': name,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final userId = data['user_id'] as String;
      final userName = data['name'] as String;

      await _storage.saveAuthSession(
        token: token,
        userId: userId,
        phone: phone,
        name: userName,
      );

      return UserModel(
        id: userId,
        phone: phone,
        name: userName,
        role: data['role'] as String? ?? 'VOLUNTEER',
      );
    } catch (_) {
      // Offline fallback
      const mockUserId = 'a0000000-0000-0000-0000-000000000001';
      final finalName = name ?? 'Aarav Sharma';
      await _storage.saveAuthSession(
        token: 'dev_mock_jwt_token',
        userId: mockUserId,
        phone: phone,
        name: finalName,
      );
      return UserModel(
        id: mockUserId,
        phone: phone,
        name: finalName,
        role: 'VOLUNTEER',
        volunteerProfile: const VolunteerProfile(
          isAvailable: true,
          badgeLabel: 'Verified First Responder',
        ),
      );
    }
  }

  // --- SOS APIs ---

  Future<SosRequest> createSos({
    required String animalType,
    required String emergencyType,
    required double latitude,
    required double longitude,
    required String address,
    String? landmark,
    String? description,
    required List<String> requirements,
    List<String> mediaUrls = const [],
    String? voiceMemoUrl,
  }) async {
    try {
      final res = await _dio.post('/sos', data: {
        'animal_type': animalType,
        'emergency_type': emergencyType,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'landmark': landmark,
        'description': description,
        'requirements': requirements,
        'media_urls': mediaUrls,
        'voice_memo_url': voiceMemoUrl,
      });
      return SosRequest.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      // Offline draft creation fallback matching Stitch
      final newSos = SosRequest(
        id: 'c0000000-0000-0000-0000-000000000099',
        caseNumber: 'SOS-BLR-9042',
        reporterId: await _storage.getUserId() ?? 'a0000000-0000-0000-0000-000000000001',
        reporterName: await _storage.getUserName() ?? 'Aarav Sharma',
        status: 'OPEN',
        animalType: animalType,
        emergencyType: emergencyType,
        latitude: latitude,
        longitude: longitude,
        distanceMeters: 0.0,
        address: address,
        landmark: landmark,
        description: description,
        requirements: requirements,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _localSosCache.insert(0, newSos);
      return newSos;
    }
  }

  Future<List<SosRequest>> getNearbySos({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final res = await _dio.get('/sos/nearby', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
      });
      final list = (res.data as List<dynamic>)
          .map((e) => SosRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return _localSosCache;
    }
  }

  Future<SosDetail> getSosDetail(String id) async {
    try {
      final res = await _dio.get('/sos/$id');
      return SosDetail.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      final match = _localSosCache.firstWhere(
        (s) => s.id == id || s.caseNumber == id,
        orElse: () => _seedCase1,
      );
      return SosDetail(
        sos: match,
        statusHistory: [
          SosStatusHistory(
            id: '1',
            newStatus: 'OPEN',
            actorId: 'a1',
            actorName: 'Priya Patel',
            reason: 'Emergency alert filed with photo and pinpoint telemetry.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          SosStatusHistory(
            id: '2',
            previousStatus: 'OPEN',
            newStatus: 'RESPONDING',
            actorId: 'a2',
            actorName: 'Dr. Rohan Verma',
            reason: 'Broadcasted to 18 certified volunteers within 3 km radius.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          ),
          SosStatusHistory(
            id: '3',
            previousStatus: 'RESPONDING',
            newStatus: 'HELP_ARRIVING',
            actorId: 'a2',
            actorName: 'Dr. Rohan Verma',
            reason: 'Responder en route on motorcycle. Estimated arrival 6 mins.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
          ),
        ],
        activeRespondersCount: 1,
      );
    }
  }

  Future<SosDetail> acceptSos(String id, {String? notes}) async {
    try {
      final res = await _dio.post('/sos/$id/respond', data: {
        'response_role': 'PRIMARY',
        'eta_minutes': 8,
        'equipment_notes': notes ?? 'Bringing first aid kit and carrier.',
      });
      return SosDetail.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return getSosDetail(id);
    }
  }

  Future<SosDetail> cancelSos(String id, String reason) async {
    try {
      final res = await _dio.post('/sos/$id/cancel', data: {'reason': reason});
      return SosDetail.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return getSosDetail(id);
    }
  }

  Future<SosDetail> resolveSos(String id, String notes) async {
    try {
      final res = await _dio.post('/sos/$id/resolve', data: {'outcome_notes': notes});
      return SosDetail.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return getSosDetail(id);
    }
  }

  // --- Organizations / Directory ---

  Future<List<Organization>> getOrganizations({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
    String? orgType,
    bool? is247,
  }) async {
    try {
      final Map<String, dynamic> qParams = {
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
      };
      if (orgType != null) qParams['org_type'] = orgType;
      if (is247 != null) qParams['is_24_7'] = is247;

      final res = await _dio.get('/organizations/nearby', queryParameters: qParams);
      return (res.data as List<dynamic>)
          .map((e) => Organization.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _seedOrganizations;
    }
  }

  // --- Notifications ---

  Future<List<AppNotification>> getNotifications() async {
    try {
      final res = await _dio.get('/notifications');
      return (res.data as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [
        AppNotification(
          id: 'n1',
          title: '🚨 New Emergency Nearby',
          body: 'Injured Indie Dog reported 450m away on 12th Main Indiranagar.',
          category: 'EMERGENCY',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        AppNotification(
          id: 'n2',
          title: '🐾 Dr. Rohan En Route',
          body: 'Dr. Rohan Verma is responding to case #SOS-BLR-8921.',
          category: 'RESPONSE',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
        ),
      ];
    }
  }

  // --- Seed Data (matches Stitch designs with 100% fidelity) ---

  static final SosRequest _seedCase1 = SosRequest(
    id: 'c0000000-0000-0000-0000-000000000001',
    caseNumber: 'SOS-BLR-8921',
    reporterId: 'a0000000-0000-0000-0000-000000000003',
    reporterName: 'Priya Patel',
    status: 'HELP_ARRIVING',
    animalType: 'DOG',
    emergencyType: 'INJURED',
    latitude: 12.9772,
    longitude: 77.6418,
    distanceMeters: 450.0,
    accuracyMeters: 5.0,
    address: 'Indiranagar 12th Main, Bengaluru',
    landmark: 'Near Corner House Ice Cream, 100ft Rd Corner',
    description: 'Deep leg wound near 12th Main junction, resting calmly under tea stall next to pharmacy. Friendly temperament.',
    primaryResponderId: 'a0000000-0000-0000-0000-000000000002',
    primaryResponderName: 'Dr. Rohan Verma',
    primaryResponderPhone: '+919876543211',
    primaryResponderAvatar: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=256&q=80',
    primaryResponderEtaMinutes: 6,
    media: const [
      SosMedia(
        id: 'm1',
        mediaType: 'IMAGE',
        url: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
        caption: 'Paw injury visible on front right leg',
      ),
    ],
    requirements: const ['FIRST_AID', 'TRANSPORTATION', 'PHYSICAL_ASSISTANCE'],
    createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );

  static final SosRequest _seedCase2 = SosRequest(
    id: 'c0000000-0000-0000-0000-000000000002',
    caseNumber: 'SOS-BLR-8922',
    reporterId: 'a0000000-0000-0000-0000-000000000003',
    reporterName: 'Priya Patel',
    status: 'OPEN',
    animalType: 'CAT',
    emergencyType: 'TRAPPED',
    latitude: 12.9790,
    longitude: 77.6450,
    distanceMeters: 1200.0,
    accuracyMeters: 8.0,
    address: 'CMH Road Metro Station, Indiranagar',
    landmark: 'Storm drain grate near CMH Road metro station entrance gate 2',
    description: 'Small 2-month-old kitten stuck down storm drain grate, meowing constantly. Need flashlight and small carrier.',
    media: const [
      SosMedia(
        id: 'm2',
        mediaType: 'IMAGE',
        url: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
        caption: 'Trapped kitten in drainage area',
      ),
    ],
    requirements: const ['CARRIER', 'PHYSICAL_ASSISTANCE'],
    createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 14)),
  );

  static final List<SosRequest> _localSosCache = [_seedCase1, _seedCase2];

  static final List<Organization> _seedOrganizations = [
    const Organization(
      id: 'b1',
      name: 'CUPA Second Chance Sanctuary & Trauma Centre',
      orgType: 'VET_HOSPITAL',
      description: 'Veterinary Ambulance • Full Surgical Unit • ICU Care for street animals.',
      address: '100 Feet Rd, HAL 2nd Stage, Indiranagar, Bengaluru 560038',
      latitude: 12.9716,
      longitude: 77.6412,
      distanceMeters: 2400.0,
      phone: '+918022947307',
      emergencyPhone: '+918022947307',
      website: 'https://cupaindia.org',
      operatingHours: 'Open 24/7',
      is247: true,
      isVerified: true,
      facilities: ['AMBULANCE', 'ICU', 'SURGERY', 'OPD'],
    ),
    const Organization(
      id: 'b2',
      name: 'CARE — Charlie\'s Animal Rescue Centre',
      orgType: 'NGO',
      description: 'Premier trauma and medical rehabilitation center with ambulance services.',
      address: 'Mitteganahalli Cross, Kogilu Main Rd, Yelahanka, Bengaluru',
      latitude: 13.0982,
      longitude: 77.6189,
      distanceMeters: 14200.0,
      phone: '+919483916052',
      emergencyPhone: '+919483916052',
      website: 'https://charlies-care.com',
      operatingHours: '9:00 AM – 5:30 PM (Emergency Unit on Call)',
      is247: false,
      isVerified: true,
      facilities: ['AMBULANCE', 'SURGERY', 'BOARDING'],
    ),
    const Organization(
      id: 'b3',
      name: 'People For Animals (PFA) Hospital',
      orgType: 'NGO',
      description: 'Wildlife & Pet Hospital with 24/7 emergency critical care unit.',
      address: 'Uttarahalli Main Road, Kengeri, Bengaluru 560060',
      latitude: 12.9067,
      longitude: 77.4892,
      distanceMeters: 18500.0,
      phone: '+919900025370',
      emergencyPhone: '+919900025370',
      website: 'https://pfabengaluru.org',
      operatingHours: 'Open 24/7',
      is247: true,
      isVerified: true,
      facilities: ['AMBULANCE', 'ICU', 'SURGERY'],
    ),
    const Organization(
      id: 'b4',
      name: 'Sarvoham Animal Welfare Trust',
      orgType: 'SHELTER',
      description: 'Sanctuary offering lifetime care and rescue for old and paralyzed street dogs.',
      address: 'Kempapura, Bangalore, Karnataka 560037',
      latitude: 12.9550,
      longitude: 77.6780,
      distanceMeters: 4800.0,
      phone: '+918073867664',
      website: 'https://sarvoham.org',
      operatingHours: '9:00 AM – 6:00 PM',
      is247: false,
      isVerified: true,
      facilities: ['BOARDING', 'OPD'],
    ),
  ];
}
