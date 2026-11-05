import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/sos_model.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';

class SosCreationState {
  final int currentStep;
  final String selectedAnimal;
  final String selectedEmergency;
  final List<String> selectedRequirements;
  final String landmarkNotes;
  final List<String> photoUrls;
  final bool hasVoiceMemo;
  final bool isSubmitting;
  final UserLocationResult location;
  final SosRequest? createdSos;
  final String? errorMessage;

  const SosCreationState({
    this.currentStep = 2, // Step 2 of 3 as in Stitch design
    this.selectedAnimal = 'DOG',
    this.selectedEmergency = 'INJURED',
    this.selectedRequirements = const ['FIRST_AID', 'TRANSPORTATION', 'PHYSICAL_ASSISTANCE'],
    this.landmarkNotes = 'Brown indie dog, limping on front right paw, friendly, sheltered under tea stall next to pharmacy.',
    this.photoUrls = const ['https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80'],
    this.hasVoiceMemo = true,
    this.isSubmitting = false,
    this.location = const UserLocationResult(
      latitude: 12.9772,
      longitude: 77.6418,
      accuracyMeters: 5.0,
      formattedAddress: 'Near Metro Pillar 84, Indiranagar, Bengaluru, Karnataka 560038',
    ),
    this.createdSos,
    this.errorMessage,
  });

  SosCreationState copyWith({
    int? currentStep,
    String? selectedAnimal,
    String? selectedEmergency,
    List<String>? selectedRequirements,
    String? landmarkNotes,
    List<String>? photoUrls,
    bool? hasVoiceMemo,
    bool? isSubmitting,
    UserLocationResult? location,
    SosRequest? createdSos,
    String? errorMessage,
  }) {
    return SosCreationState(
      currentStep: currentStep ?? this.currentStep,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      selectedEmergency: selectedEmergency ?? this.selectedEmergency,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      landmarkNotes: landmarkNotes ?? this.landmarkNotes,
      photoUrls: photoUrls ?? this.photoUrls,
      hasVoiceMemo: hasVoiceMemo ?? this.hasVoiceMemo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      location: location ?? this.location,
      createdSos: createdSos ?? this.createdSos,
      errorMessage: errorMessage,
    );
  }
}

class SosCreationNotifier extends StateNotifier<SosCreationState> {
  final ApiClient _apiClient;

  SosCreationNotifier(this._apiClient, UserLocationResult location)
      : super(SosCreationState(location: location));

  void selectAnimal(String animal) {
    state = state.copyWith(selectedAnimal: animal);
  }

  void selectEmergency(String emergency) {
    state = state.copyWith(selectedEmergency: emergency);
  }

  void toggleRequirement(String requirement) {
    final list = List<String>.from(state.selectedRequirements);
    if (list.contains(requirement)) {
      list.remove(requirement);
    } else {
      list.add(requirement);
    }
    state = state.copyWith(selectedRequirements: list);
  }

  void setLandmarkNotes(String notes) {
    state = state.copyWith(landmarkNotes: notes);
  }

  void toggleVoiceMemo() {
    state = state.copyWith(hasVoiceMemo: !state.hasVoiceMemo);
  }

  Future<SosRequest?> publishSos() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final sos = await _apiClient.createSos(
        animalType: state.selectedAnimal,
        emergencyType: state.selectedEmergency,
        latitude: state.location.latitude,
        longitude: state.location.longitude,
        address: state.location.formattedAddress,
        landmark: state.landmarkNotes,
        description: state.landmarkNotes,
        requirements: state.selectedRequirements,
        mediaUrls: state.photoUrls,
        voiceMemoUrl: state.hasVoiceMemo ? 'https://example.com/voice-memo-12s.m4a' : null,
      );

      state = state.copyWith(isSubmitting: false, createdSos: sos);
      return sos;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Failed to publish SOS: $e');
      return null;
    }
  }
}

final sosCreationProvider = StateNotifierProvider<SosCreationNotifier, SosCreationState>((ref) {
  final api = ref.watch(apiClientProvider);
  final homeState = ref.watch(homeNotifierProvider);
  return SosCreationNotifier(api, homeState.location);
});

