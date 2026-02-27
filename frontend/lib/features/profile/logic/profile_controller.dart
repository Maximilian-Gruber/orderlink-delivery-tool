import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/api/api_client.dart';
import '../data/profile_api.dart';
import '../models/profile_model.dart';

class ProfileState {
  final bool loading;
  final Profile? profile;
  final String? error;

  ProfileState({
    this.loading = false, 
    this.profile, 
    this.error
  });

  ProfileState copyWith({
    bool? loading, 
    Profile? profile, 
    String? error
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}

final profileApiProvider = Provider.autoDispose<ProfileApi>((ref) {
  final client = ref.read(apiClientProvider);
  return ProfileApi(client);
});

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ProfileState>((ref) {
  return ProfileController(ref);
});

class ProfileController extends StateNotifier<ProfileState> {
  final Ref ref;
  late final ProfileApi _api;

  ProfileController(this.ref) : super(ProfileState()) {
    _api = ref.read(profileApiProvider);
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(loading: true, error: null);
    
    try {
      final profile = await _api.fetchProfile();
      state = state.copyWith(
        profile: profile,
        loading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(), 
        loading: false
      );
    }
  }

  Future<void> refresh() async => await fetchProfile();
}