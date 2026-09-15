import '../../core/exceptions/app_exception.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository(this._dataSource);

  final ProductLocalDataSource _dataSource;

  Future<List<Product>> getProducts() async {
    try {
      return await _dataSource.fetchProducts();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Le catalogue est temporairement indisponible.');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final products = await _dataSource.fetchProducts();
      for (final product in products) {
        if (product.id == id) return product;
      }
      throw const AppException('Ce produit est introuvable.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Impossible d\'ouvrir la fiche produit.');
    }
  }
}
