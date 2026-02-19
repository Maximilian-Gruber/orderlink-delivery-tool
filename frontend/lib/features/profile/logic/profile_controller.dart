import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/api/api_client.dart';
import '../data/profile_api.dart';
import '../models/profile_model.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  final client = ref.read(apiClientProvider);
  return ProfileApi(client);
});

final profileProvider = FutureProvider<Profile>((ref) async {
  final api = ref.read(profileApiProvider);
  return await api.fetchProfile();
});