import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import '../data/auth_api.dart';

class AuthState {
  final bool loading;
  final String? token;
  final String? error;

  AuthState({this.loading = false, this.token, this.error});

  AuthState copyWith({bool? loading, String? token, String? error}) {
    return AuthState(
      loading: loading ?? this.loading,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  late final SecureStorage storage;
  late final AuthApi api;

  AuthController(this.ref) : super(AuthState()) {
    storage = SecureStorage();
    api = AuthApi(ApiClient(storage: storage));
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await storage.getToken();
    if (token != null) {
      state = state.copyWith(token: token);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await api.login(email, password);
      await storage.saveToken(token);
      state = state.copyWith(token: token, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
