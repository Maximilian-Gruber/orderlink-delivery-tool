import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Für VoidCallback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config.dart';
import '../storage/secure_storage.dart';
// Importiere den AuthController, um die Logout-Methode aufzurufen
import '../../features/auth/logic/auth_controller.dart'; 

class ApiClient {
  final Dio dio;
  final SecureStorage storage;
  final VoidCallback? onTokenExpired; // Callback für 401 Fehler

  ApiClient({
    required this.storage,
    this.onTokenExpired,
  }) : dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
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
            // 1. Speicher löschen
            await storage.clear();
            print("Token abgelaufen - Trigger Logout");
            
            // 2. AuthController benachrichtigen (falls Callback gesetzt)
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

// Der Provider verknüpft nun ApiClient und AuthController
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = SecureStorage();
  
  return ApiClient(
    storage: storage,
    onTokenExpired: () {
      // Hier schließen wir den Kreis: Bei 401 wird ausgeloggt.
      // Der Router (app_router.dart) merkt das sofort und redirectet zum Login.
      ref.read(authControllerProvider.notifier).logout();
    },
  );
});