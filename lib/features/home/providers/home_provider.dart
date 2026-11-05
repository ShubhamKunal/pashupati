import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/organization_model.dart';
import '../../../shared/models/sos_model.dart';
import '../../authentication/providers/auth_provider.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

class HomeState {
  final bool isLoading;
  final UserLocationResult location;
  final List<SosRequest> incidents;
  final List<Organization> emergencyCenters;
  final bool isResponderActive;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.location = const UserLocationResult(
      latitude: 12.9784,
      longitude: 77.6408,
      accuracyMeters: 8.0,
      formattedAddress: 'Indiranagar, Bengaluru • GPS (±8m)',
    ),
    this.incidents = const [],
    this.emergencyCenters = const [],
    this.isResponderActive = true,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    UserLocationResult? location,
    List<SosRequest>? incidents,
    List<Organization>? emergencyCenters,
    bool? isResponderActive,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      location: location ?? this.location,
      incidents: incidents ?? this.incidents,
      emergencyCenters: emergencyCenters ?? this.emergencyCenters,
      isResponderActive: isResponderActive ?? this.isResponderActive,
      errorMessage: errorMessage,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ApiClient _apiClient;
  final LocationService _locationService;

  HomeNotifier(this._apiClient, this._locationService) : super(const HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loc = await _locationService.getCurrentLocation();
      final incidents = await _apiClient.getNearbySos(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      final orgs = await _apiClient.getOrganizations(
        latitude: loc.latitude,
        longitude: loc.longitude,
        is247: true,
      );

      state = state.copyWith(
        isLoading: false,
        location: loc,
        incidents: incidents,
        emergencyCenters: orgs,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load feed: $e');
    }
  }

  void toggleResponderStatus() {
    state = state.copyWith(isResponderActive: !state.isResponderActive);
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final api = ref.watch(apiClientProvider);
  final loc = ref.watch(locationServiceProvider);
  return HomeNotifier(api, loc);
});
