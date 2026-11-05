import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/models/user_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final storageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;
  final String? devOtp;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.devOtp,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
    String? devOtp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
      devOtp: devOtp,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthNotifier(this._apiClient, this._storage) : super(const AuthState()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    final loggedIn = await _storage.isLoggedIn();
    if (loggedIn) {
      final name = await _storage.getUserName() ?? 'Aarav Sharma';
      final phone = await _storage.getUserPhone() ?? '+919876543210';
      final userId = await _storage.getUserId() ?? 'a0000000-0000-0000-0000-000000000001';

      state = state.copyWith(
        isAuthenticated: true,
        user: UserModel(
          id: userId,
          phone: phone,
          name: name,
          role: 'VOLUNTEER',
          volunteerProfile: const VolunteerProfile(
            isAvailable: true,
            badgeLabel: 'Verified First Responder',
          ),
        ),
      );
    }
  }

  Future<bool> requestOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.requestOtp(phone);
      final devOtp = res['dev_otp'] as String?;
      state = state.copyWith(isLoading: false, devOtp: devOtp);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to request OTP: $e');
      return false;
    }
  }

  Future<bool> verifyOtp({required String phone, required String otp, String? name}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _apiClient.verifyOtp(phone: phone, otp: otp, name: name);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Verification failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearSession();
    state = const AuthState(isAuthenticated: false, user: null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(apiClientProvider);
  final storage = ref.watch(storageProvider);
  return AuthNotifier(api, storage);
});

