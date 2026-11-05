class AppConfig {
  static const String appName = 'PASHUPATI';
  static const String appTagline = 'Be the reason a life survives.';
  static const String appVersion = '1.0.0';

  // Network configuration
  static const String defaultApiBaseUrl = 'http://10.0.2.2:8080/api/v1';
  static const String defaultWsBaseUrl = 'ws://10.0.2.2:8080/api/v1/ws';
  static const Duration requestTimeout = Duration(seconds: 15);

  // Default Bengaluru center for development/testing
  static const double defaultLatitude = 12.9784;
  static const double defaultLongitude = 77.6408;
  static const String defaultLocationName = 'Indiranagar, Bengaluru';
}

