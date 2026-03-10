import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/dashboard/models/route_model.dart';

class ActiveRouteApi {
  final ApiClient client;
  ActiveRouteApi(this.client);

  Future<RouteOrders> fetchRouteOrdersFastest(String routeId, {double? lat, double? lon}) async {
  final response = await client.get(
    '/routes/$routeId/orders/fastest',
    queryParameters: {
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    },
  );
  return RouteOrders.fromJson(response.data);
}
}