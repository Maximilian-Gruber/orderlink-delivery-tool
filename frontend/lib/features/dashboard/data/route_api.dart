import '../../../../core/api/api_client.dart';
import '../models/route_model.dart';

class RouteApi {
  final ApiClient client;
  RouteApi(this.client);

  Future<List<RouteCustomers>> fetchActiveRoutes() async {
    try {
      final response = await client.get('/routes/active-routes-with-orders-products');
      
      if (response.data == null) return [];
      
      return (response.data as List)
          .map((e) => RouteCustomers.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<RouteOrders> fetchRouteOrders(String routeId) async {
    final response = await client.get('/routes/$routeId/orders');
    return RouteOrders.fromJson(response.data);
  }
}