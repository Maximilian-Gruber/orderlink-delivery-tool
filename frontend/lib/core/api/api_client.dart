import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/logic/auth_controller.dart'; 

class ApiClient {
  final Dio dio;
  final SecureStorage storage;
  final VoidCallback? onTokenExpired;

  ApiClient({
    required this.storage,
    this.onTokenExpired,
  }) : dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 7),
        )) {
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await storage.clear();
            
            if (onTokenExpired != null) {
              onTokenExpired!();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = SecureStorage();
  
  return ApiClient(
    storage: storage,
    onTokenExpired: () {
      ref.read(authControllerProvider.notifier).logout();
    },
  );
});