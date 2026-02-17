import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';
import '../data/route_api.dart';
import '../models/route_model.dart';
import '../../auth/logic/auth_controller.dart';

class DashboardState {
  final bool loading;
  final List<RouteCustomers> routes;
  final String? error;

  DashboardState({
    this.loading = false,
    this.routes = const [],
    this.error,
  });

  DashboardState copyWith({
    bool? loading,
    List<RouteCustomers>? routes,
    String? error,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      routes: routes ?? this.routes,
      error: error ?? this.error,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final Ref ref;
  late final RouteApi _api;

  DashboardController(this.ref) : super(DashboardState()) {
    _api = RouteApi(ref.read(apiClientProvider));
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    final token = ref.read(authControllerProvider).token;
    if (token == null) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final routes = await _api.fetchActiveRoutes();
      state = state.copyWith(routes: routes, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Fehler: $e",
        loading: false,
      );
    }
  }

  Future<void> refresh() async {
    await fetchRoutes();
  }

  Future<RouteOrders?> getRouteDetails(String routeId) async {
    try {
      return await _api.fetchRouteOrders(routeId);
    } catch (e) {
      return null;
    }
  }

}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref);
});