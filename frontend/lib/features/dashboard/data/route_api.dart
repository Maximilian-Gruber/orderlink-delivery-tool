import '../../../../core/api/api_client.dart';
import '../models/route_model.dart';
import 'package:dio/dio.dart';

class RouteApi {
  final ApiClient client;
  RouteApi(this.client);

  Future<List<RouteCustomers>> fetchActiveRoutes() async {
    try {
      final response = await client.get('/routes/active-routes-with-orders-products');
      return (response.data as List)
          .map((e) => RouteCustomers.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Fehler beim Laden der Routen: ${e.message}');
    }
  }
}