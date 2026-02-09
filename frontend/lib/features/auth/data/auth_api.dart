import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class AuthApi {
  final ApiClient client;

  AuthApi(this.client);

  Future<String> login(String email, String password) async {
    final formData = FormData.fromMap({
      'username': email,
      'password': password,
    });

    final res = await client.dio.post('/auth/login', data: formData);
    return res.data['access_token'];
  }
}
