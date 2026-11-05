import 'package:flutter_test/flutter_test.dart';
import 'package:pashupati/shared/models/sos_model.dart';
import 'package:pashupati/shared/models/user_model.dart';
import 'package:pashupati/shared/models/organization_model.dart';

void main() {
  group('Pashupati Domain Models Unit Tests', () {
    test('SosRequest deserializes correctly from backend JSON', () {
      final json = {
        'id': 'c0000000-0000-0000-0000-000000000001',
        'case_number': 'SOS-BLR-8921',
        'reporter_id': 'a0000000-0000-0000-0000-000000000003',
        'reporter_name': 'Priya Patel',
        'status': 'HELP_ARRIVING',
        'animal_type': 'DOG',
        'emergency_type': 'INJURED',
        'latitude': 12.9772,
        'longitude': 77.6418,
        'distance_meters': 450.0,
        'accuracy_meters': 5.0,
        'address': 'Indiranagar 12th Main, Bengaluru',
        'landmark': 'Near Corner House',
        'description': 'Injured indie dog under tea stall',
        'primary_responder_id': 'a0000000-0000-0000-0000-000000000002',
        'primary_responder_name': 'Dr. Rohan Verma',
        'primary_responder_eta_minutes': 6,
        'media': [
          {
            'id': 'm1',
            'media_type': 'IMAGE',
            'url': 'https://example.com/dog.jpg',
            'caption': 'Paw injury',
          }
        ],
        'requirements': ['FIRST_AID', 'TRANSPORTATION'],
        'created_at': '2026-11-05T12:00:00Z',
        'updated_at': '2026-11-05T12:05:00Z',
      };

      final sos = SosRequest.fromJson(json);

      expect(sos.id, 'c0000000-0000-0000-0000-000000000001');
      expect(sos.caseNumber, 'SOS-BLR-8921');
      expect(sos.status, 'HELP_ARRIVING');
      expect(sos.animalType, 'DOG');
      expect(sos.emergencyType, 'INJURED');
      expect(sos.formattedDistance, '450m away');
      expect(sos.isActive, true);
      expect(sos.media.length, 1);
      expect(sos.requirements, contains('FIRST_AID'));
      expect(sos.primaryResponderName, 'Dr. Rohan Verma');
      expect(sos.primaryResponderEtaMinutes, 6);
    });

    test('Distance formatting formats meters and kilometers accurately', () {
      final shortDist = SosRequest(
        id: '1',
        caseNumber: 'SOS-1',
        reporterId: 'u1',
        status: 'OPEN',
        animalType: 'DOG',
        emergencyType: 'INJURED',
        latitude: 12.0,
        longitude: 77.0,
        distanceMeters: 750.0,
        address: 'Test Rd',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(shortDist.formattedDistance, '750m away');

      final longDist = SosRequest(
        id: '2',
        caseNumber: 'SOS-2',
        reporterId: 'u1',
        status: 'OPEN',
        animalType: 'DOG',
        emergencyType: 'INJURED',
        latitude: 12.0,
        longitude: 77.0,
        distanceMeters: 3400.0,
        address: 'Test Rd',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(longDist.formattedDistance, '3.4 km away');
    });

    test('UserModel and VolunteerProfile deserialize correctly', () {
      final json = {
        'id': 'u100',
        'phone': '+919876543210',
        'name': 'Aarav Sharma',
        'role': 'VOLUNTEER',
        'volunteer_profile': {
          'is_available': true,
          'verification_status': 'VERIFIED',
          'vehicle_type': 'TWO_WHEELER',
          'capabilities': ['FIRST_AID', 'TRANSPORT'],
          'response_radius_km': 8,
          'rescues_completed_count': 23,
          'badge_label': 'Verified First Responder',
        }
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'u100');
      expect(user.name, 'Aarav Sharma');
      expect(user.role, 'VOLUNTEER');
      expect(user.volunteerProfile?.isAvailable, true);
      expect(user.volunteerProfile?.badgeLabel, 'Verified First Responder');
      expect(user.volunteerProfile?.responseRadiusKm, 8);
    });

    test('Organization parses 24/7 status and emergency contacts', () {
      final json = {
        'id': 'org1',
        'name': 'CUPA Second Chance Sanctuary & Trauma Centre',
        'org_type': 'VET_HOSPITAL',
        'address': '100 Feet Rd, Indiranagar',
        'latitude': 12.9716,
        'longitude': 77.6412,
        'distance_meters': 2400.0,
        'phone': '+918022947307',
        'emergency_phone': '+918022947307',
        'is_24_7': true,
        'is_verified': true,
        'facilities': ['AMBULANCE', 'ICU', 'SURGERY'],
      };

      final org = Organization.fromJson(json);

      expect(org.name, 'CUPA Second Chance Sanctuary & Trauma Centre');
      expect(org.is247, true);
      expect(org.isVerified, true);
      expect(org.emergencyPhone, '+918022947307');
      expect(org.formattedDistance, '2.4 km away');
    });
  });
}

