import 'package:app_e_commerce_avec_riverpod/app.dart';
import 'package:app_e_commerce_avec_riverpod/core/constants/app_strings.dart';
import 'package:app_e_commerce_avec_riverpod/data/models/product.dart';
import 'package:app_e_commerce_avec_riverpod/data/models/user_profile.dart';
import 'package:app_e_commerce_avec_riverpod/providers/dependency_providers.dart';
import 'package:app_e_commerce_avec_riverpod/providers/product_providers.dart';
import 'package:app_e_commerce_avec_riverpod/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testProduct = Product(
  id: 't1',
  name: 'Produit test',
  description: 'Description de test',
  price: 19.90,
  imageUrl: '',
  category: 'Mode',
  rating: 4.5,
  reviewCount: 10,
  stock: 5,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('affiche le catalogue et permet d\'ajouter au panier', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          productsProvider.overrideWith((ref) async => [_testProduct]),
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(
              id: 'u-test',
              fullName: 'Test User',
              email: 'test@novashop.dev',
              phone: '+228 00 00 00 00',
              city: 'Lomé',
              memberSince: '2026',
              orderCount: 0,
            ),
          ),
        ],
        child: const NovaShopApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppStrings.catalogTitle), findsWidgets);
    expect(find.text('Produit test'), findsOneWidget);

    await tester.tap(find.text(AppStrings.addToCart));
    await tester.pump();
    await tester.tap(find.text(AppStrings.cartTitle));
    await tester.pumpAndSettle();

    expect(find.text('Produit test'), findsWidgets);
    expect(find.text(AppStrings.total), findsOneWidget);
  });
}
