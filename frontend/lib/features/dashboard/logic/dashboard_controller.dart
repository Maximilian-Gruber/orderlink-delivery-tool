import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';
import 'package:dio/dio.dart';
import '../data/route_api.dart';
import '../models/route_model.dart';

class DashboardState {
  final bool loading;
  final List<RouteCustomers> allRoutes;
  final List<RouteCustomers> filteredRoutes;
  final String searchQuery;
  final String? error;

  DashboardState({
    this.loading = false,
    this.allRoutes = const [],
    this.filteredRoutes = const [],
    this.searchQuery = '',
    this.error,
  });

  DashboardState copyWith({
    bool? loading,
    List<RouteCustomers>? allRoutes,
    List<RouteCustomers>? filteredRoutes,
    String? searchQuery,
    String? error,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      allRoutes: allRoutes ?? this.allRoutes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      searchQuery: searchQuery ?? this.searchQuery,
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
      
      state = state.copyWith(
        allRoutes: routes,
        filteredRoutes: routes,
        loading: false,
        error: null, 
      );

      if (state.searchQuery.isNotEmpty) {
        updateSearch(state.searchQuery);
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      String errorKey = (e.type == DioExceptionType.connectionTimeout || 
                         e.type == DioExceptionType.receiveTimeout) 
                         ? "timeout" : "load_error";
      
      state = state.copyWith(error: errorKey, loading: false);
    } catch (e) {
      print("General Error: $e"); 
      state = state.copyWith(error: "load_error", loading: false);
    }
  }

  void updateSearch(String query) {
    final filtered = state.allRoutes.where((route) {
      final matchesRoute = route.routeName.toLowerCase().contains(query.toLowerCase());
      final matchesCustomer = route.customers.any(
          (c) => c.customerName.toLowerCase().contains(query.toLowerCase()));
      return matchesRoute || matchesCustomer;
    }).toList();

    state = state.copyWith(searchQuery: query, filteredRoutes: filtered);
  }

  Future<void> refresh() async => await fetchRoutes();

  Future<RouteOrders?> getRouteDetails(String routeId) async {
    try {
      return await _api.fetchRouteOrders(routeId);
    } catch (e) {
      return null;
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider.autoDispose<DashboardController, DashboardState>((ref) {
      return DashboardController(ref);
});