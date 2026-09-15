import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_profile.dart';
import 'dependency_providers.dart';

/// Profil utilisateur mocké, exposé en [AsyncValue].
final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(userRepositoryProvider).getProfile();
});
