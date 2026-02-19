import '../../../../core/api/api_client.dart';
import '../models/profile_model.dart';

class ProfileApi {
  final ApiClient client;
  ProfileApi(this.client);

  Future<Profile> fetchProfile() async {
    final response = await client.get('/employees/profile');
    return Profile.fromJson(response.data);

  }

}