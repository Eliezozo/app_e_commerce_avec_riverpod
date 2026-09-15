import '../../core/exceptions/app_exception.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepository {
  FavoritesRepository(this._dataSource);

  final FavoritesLocalDataSource _dataSource;

  Future<Set<String>> loadIds() async {
    try {
      return await _dataSource.loadIds();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Impossible de charger vos favoris.');
    }
  }

  Future<void> saveIds(Set<String> ids) async {
    try {
      await _dataSource.saveIds(ids);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Impossible d\'enregistrer vos favoris.');
    }
  }
}
