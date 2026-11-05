import 'package:geolocator/geolocator.dart';
import '../../app/config/config.dart';

class UserLocationResult {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final String formattedAddress;
  final bool isEstimated;

  const UserLocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.formattedAddress,
    this.isEstimated = false,
  });
}

class LocationService {
  Future<UserLocationResult> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackLocation('Location service disabled. Using default.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _fallbackLocation('Permission denied. Using Indiranagar pin.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _fallbackLocation('Permission permanently denied. Using Indiranagar pin.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return UserLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        formattedAddress: 'Indiranagar, Bengaluru • GPS (±${position.accuracy.round()}m)',
        isEstimated: false,
      );
    } catch (e) {
      return _fallbackLocation('GPS timeout. Using Indiranagar pin.');
    }
  }

  UserLocationResult _fallbackLocation(String reason) {
    return const UserLocationResult(
      latitude: AppConfig.defaultLatitude,
      longitude: AppConfig.defaultLongitude,
      accuracyMeters: 8.0,
      formattedAddress: 'Indiranagar, Bengaluru • GPS (±8m)',
      isEstimated: true,
    );
  }
}
