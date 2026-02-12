import '../../../core/api/api_client.dart';
import '../models/site_config_model.dart';

class SiteConfigApi {
  final ApiClient client;

  SiteConfigApi(this.client);

  Future<SiteConfigLoginPage> fetchConfig() async {
    final res =
        await client.dio.get('/site-config/login-page');

    return SiteConfigLoginPage.fromJson(res.data);
  }
}
