import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/product.dart';

/// Charge le catalogue depuis un JSON local (fausse API avec latence).
class ProductLocalDataSource {
  ProductLocalDataSource({
    AssetBundle? bundle,
    this.simulatedDelay = const Duration(milliseconds: 700),
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Duration simulatedDelay;

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(simulatedDelay);
    try {
      final raw = await _bundle.loadString(AppAssets.productsJson);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const AppException('Format du catalogue invalide.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .where((product) => product.id.isNotEmpty)
          .toList(growable: false);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Impossible de charger le catalogue. Vérifiez votre connexion.',
      );
    }
  }
}
