import 'package:shared_preferences/shared_preferences.dart';

import '../../core/exceptions/app_exception.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._prefs);

  static const _key = 'favorite_product_ids';

  final SharedPreferences _prefs;

  Future<Set<String>> loadIds() async {
    try {
      final stored = _prefs.getStringList(_key) ?? const <String>[];
      return stored.toSet();
    } catch (_) {
      throw const AppException('Impossible de lire les favoris enregistrés.');
    }
  }

  Future<void> saveIds(Set<String> ids) async {
    try {
      final saved = await _prefs.setStringList(_key, ids.toList(growable: false));
      if (!saved) {
        throw const AppException('Impossible d\'enregistrer les favoris.');
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Impossible d\'enregistrer les favoris.');
    }
  }
}
