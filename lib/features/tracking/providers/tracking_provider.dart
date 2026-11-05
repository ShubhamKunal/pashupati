import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/sos_model.dart';
import '../../authentication/providers/auth_provider.dart';

class TrackingState {
  final bool isLoading;
  final SosDetail? detail;
  final String? errorMessage;
  final bool isActionInProgress;

  const TrackingState({
    this.isLoading = false,
    this.detail,
    this.errorMessage,
    this.isActionInProgress = false,
  });

  TrackingState copyWith({
    bool? isLoading,
    SosDetail? detail,
    String? errorMessage,
    bool? isActionInProgress,
  }) {
    return TrackingState(
      isLoading: isLoading ?? this.isLoading,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final ApiClient _apiClient;
  final String sosId;

  TrackingNotifier(this._apiClient, this.sosId) : super(const TrackingState()) {
    loadTrackingData();
  }

  Future<void> loadTrackingData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final detail = await _apiClient.getSosDetail(sosId);
      state = state.copyWith(isLoading: false, detail: detail);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load tracking data: $e');
    }
  }

  Future<bool> markAssistanceReceived() async {
    state = state.copyWith(isActionInProgress: true);
    try {
      final updated = await _apiClient.resolveSos(sosId, 'Assistance safely received on-site.');
      state = state.copyWith(isActionInProgress: false, detail: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isActionInProgress: false, errorMessage: 'Failed to update: $e');
      return false;
    }
  }

  Future<bool> cancelSos(String reason) async {
    state = state.copyWith(isActionInProgress: true);
    try {
      final updated = await _apiClient.cancelSos(sosId, reason);
      state = state.copyWith(isActionInProgress: false, detail: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isActionInProgress: false, errorMessage: 'Failed to cancel: $e');
      return false;
    }
  }
}

final trackingProviderFamily = StateNotifierProvider.family<TrackingNotifier, TrackingState, String>((ref, sosId) {
  final api = ref.watch(apiClientProvider);
  return TrackingNotifier(api, sosId);
});

