import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/dashboard/data/route_api.dart';
import 'package:frontend/features/dashboard/models/route_model.dart';

class ActiveRouteState {
  final bool loading;
  final String? error;
  final String? routeName;
  final List<RouteOrder> orders;

  ActiveRouteState({
    this.loading = false,
    this.error,
    this.routeName,
    this.orders = const [],
  });

  ActiveRouteState copyWith({
    bool? loading,
    String? error,
    String? routeName,
    List<RouteOrder>? orders,
  }) {
    return ActiveRouteState(
      loading: loading ?? this.loading,
      error: error,
      routeName: routeName ?? this.routeName,
      orders: orders ?? this.orders,
    );
  }
}

class ActiveRouteController extends StateNotifier<ActiveRouteState> {
  final Ref ref;
  final String routeId;
  late final RouteApi _api;

  ActiveRouteController(this.ref, this.routeId) : super(ActiveRouteState()) {
    _api = RouteApi(ref.read(apiClientProvider));
    loadRouteOrders();
  }

  Future<void> loadRouteOrders() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final routeDetails = await _api.fetchRouteOrders(routeId);
      state = state.copyWith(
        loading: false,
        routeName: routeDetails.routeName,
        orders: routeDetails.orders,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: "errorWhileLoading");
    }
  }

  void reorderOrders(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<RouteOrder> currentOrders = List.from(state.orders);
    final RouteOrder item = currentOrders.removeAt(oldIndex);
    currentOrders.insert(newIndex, item);
    
    state = state.copyWith(orders: currentOrders);
  }
}

final activeRouteControllerProvider = StateNotifierProvider.family.autoDispose<ActiveRouteController, ActiveRouteState, String>((ref, routeId) {
  return ActiveRouteController(ref, routeId);
});