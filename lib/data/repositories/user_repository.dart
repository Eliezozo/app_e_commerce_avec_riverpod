import '../../core/exceptions/app_exception.dart';
import '../models/user_profile.dart';

/// Profil mocké : simule un appel API sans backend.
class UserRepository {
  UserRepository({
    this.simulatedDelay = const Duration(milliseconds: 500),
  });

  final Duration simulatedDelay;

  Future<UserProfile> getProfile() async {
    try {
      await Future<void>.delayed(simulatedDelay);
      return const UserProfile(
        id: 'u-42',
        fullName: 'Amina Koffi',
        email: 'amina.koffi@novashop.dev',
        phone: '+228 90 12 34 56',
        city: 'Lomé, Togo',
        memberSince: 'Mars 2024',
        orderCount: 7,
      );
    } catch (_) {
      throw const AppException('Impossible de charger le profil.');
    }
  }
}
