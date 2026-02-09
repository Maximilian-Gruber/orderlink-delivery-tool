import 'package:dio/dio.dart';
import 'package:frontend/core/config.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage storage;

  ApiClient({required this.storage})
      : dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
