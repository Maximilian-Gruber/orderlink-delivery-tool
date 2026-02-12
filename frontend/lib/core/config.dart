
// Change in production
class AppConfig {
  AppConfig._();

  static const String baseUrl = "http://localhost:8000";
  static const String supabaseUrl = "https://xjxfzdsartdrkjfyrbfs.supabase.co";
  static const supabasePublicBucket = "images";

    static String get publicStorageBase =>
      "$supabaseUrl/storage/v1/object/public/$supabasePublicBucket";
}

