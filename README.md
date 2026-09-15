# Nova Shop — E-commerce Flutter + Riverpod

Application e-commerce Flutter réalisée pour valider la maîtrise du **state management avec Riverpod**. Le catalogue, le panier, les favoris persistés, le filtrage/tri et le profil utilisateur y sont implémentés avec une architecture en couches.

---

## Fonctionnalités

| Fonctionnalité | Détail |
| --- | --- |
| Catalogue | Grille de produits + fiche détail (Hero, stock, avis) |
| Panier | Ajout, quantité +, −, suppression, total |
| Favoris | Cœur sur chaque produit, persistés via `SharedPreferences` |
| Filtrage & tri | Recherche, catégories, tri nom / prix / note |
| Profil | Utilisateur mocké (identité, commandes, coordonnées) |
| Bonus | Animation d’icône qui vole vers le panier à l’ajout |

Les données produits viennent d’un **JSON local** (`assets/data/products.json`) avec une latence simulée, pour exercer `AsyncValue` (chargement, erreur, données).

---

## Stack

- Flutter 3.x / Dart 3
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) `^2.6.1` — `FutureProvider`, `StateNotifierProvider`, `Provider`
- [shared_preferences](https://pub.dev/packages/shared_preferences) — persistance des favoris
- Material 3, thème sombre

---

## Architecture

La logique métier n’est **jamais** dans les widgets. Flux : **modèle → datasource → repository → provider → UI**.

```text
lib/
├── main.dart                          # ProviderScope + SharedPreferences
├── app.dart                           # MaterialApp
├── core/                              # thème, constantes, exceptions, widgets UI génériques
│   ├── constants/
│   ├── exceptions/app_exception.dart
│   ├── theme/
│   └── widgets/                       # skeleton, empty, error, image réseau
├── data/
│   ├── models/                        # Product, CartItem, CatalogFilter, UserProfile
│   ├── datasources/                   # JSON local, SharedPreferences
│   └── repositories/                  # try/catch → AppException
├── providers/                         # toute la logique d'état Riverpod
└── presentation/
    ├── shell/main_shell.dart          # NavigationBar (4 onglets)
    ├── catalog/
    ├── cart/
    ├── favorites/
    └── profile/
assets/data/products.json              # fausse API
```

| Couche | Rôle |
| --- | --- |
| **UI** (`presentation/`) | Affiche `AsyncValue.when(loading, error, data)`. Aucun JSON, aucun `SharedPreferences`. |
| **Providers** | Orchestrent repositories et état (panier, filtres, favoris). |
| **Repositories** | Règles métier + mapping d’erreurs vers `AppException`. |
| **Datasources** | I/O (asset JSON, préférences locales). |

---

## Providers utilisés (≥ 5)

### 1. `productsProvider` — `FutureProvider<List<Product>>`

Charge le catalogue (JSON + délai). Expose un **`AsyncValue`** : skeleton pendant le chargement, message d’erreur + bouton *Réessayer*.

Fichier : `lib/providers/product_providers.dart`

### 2. `productByIdProvider` — `FutureProvider.family<Product, String>`

Fiche produit. Réutilise le cache du catalogue quand il est déjà chargé.

### 3. `cartProvider` — `StateNotifierProvider<CartNotifier, List<CartItem>>`

État du panier : `add`, `increment`, `decrement`, `remove`, `clear`. Respecte le stock.

Fichier : `lib/providers/cart_provider.dart`

Providers dérivés :

- `cartItemCountProvider` — badge de la barre de navigation
- `cartTotalProvider` / `formattedCartTotalProvider` — total à payer

### 4. `favoritesProvider` — `StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>`

IDs favoris chargés puis sauvegardés localement. `toggle(id)` met à jour l’UI puis persiste.

Fichier : `lib/providers/favorites_provider.dart`

Providers dérivés :

- `isFavoriteProvider(productId)` — cœur plein / vide
- `favoriteProductsProvider` — liste des produits favoris (`AsyncValue`)

### 5. `catalogFilterProvider` — `StateNotifierProvider<CatalogFilterNotifier, CatalogFilter>`

Recherche, catégorie et critère de tri.

Fichier : `lib/providers/catalog_filter_provider.dart`

### 6. `filteredProductsProvider` — `Provider<AsyncValue<List<Product>>>`

Liste dérivée (filtre + tri) à partir de `productsProvider` + `catalogFilterProvider`. Pas d’I/O.

### 7. `userProfileProvider` — `FutureProvider<UserProfile>`

Profil mocké (Amina Koffi, Lomé) avec latence simulée.

Fichier : `lib/providers/user_provider.dart`

### Injection

| Provider | Type | Rôle |
| --- | --- | --- |
| `sharedPreferencesProvider` | `Provider` | Injecté au `main()` via `overrides` |
| `productRepositoryProvider` | `Provider` | Accès catalogue |
| `favoritesRepositoryProvider` | `Provider` | Accès favoris |
| `userRepositoryProvider` | `Provider` | Accès profil mock |

---

## États asynchrones (`AsyncValue`)

Chaque écran asynchrone suit le même pattern :

```dart
asyncValue.when(
  loading: () => const CatalogSkeleton(),
  error: (error, _) => AsyncErrorView(
    message: error is AppException ? error.message : AppStrings.loadError,
    onRetry: () => ref.invalidate(productsProvider),
  ),
  data: (items) => GridView.builder(/* ... */),
);
```

- **Chargement** : skeleton (grille animée), jamais d’écran blanc.
- **Erreur** : message en français simple + *Réessayer*.
- **Données** : liste / grille ; empty state si le filtre ne matche rien.

---

## Lancer le projet

```bash
flutter pub get
flutter run
```

Tests :

```bash
flutter test
flutter analyze
```

---

## Parcours de démo

1. Ouvrir **Catalogue** — attendre le skeleton, puis les 16 produits.
2. Filtrer par catégorie **Mode**, trier par **Prix croissant**.
3. Ajouter un article : l’icône vole vers le panier, le badge s’incrémente.
4. Ouvrir le **détail**, basculer le favori (cœur).
5. Onglet **Favoris** — le produit est encore là après un redémarrage de l’app.
6. Onglet **Panier** — modifier la quantité, supprimer, voir le total.
7. Onglet **Profil** — identité mockée et compteurs (commandes, favoris, panier).

---

## Choix techniques

- **Riverpod 2 + `StateNotifierProvider`** : correspond aux exigences du brief (`StateNotifierProvider`, `FutureProvider`, etc.).
- **JSON local plutôt qu’une API distante** : hors-ligne, reproductible, suffisant pour `AsyncValue`.
- **Favoris seuls persistés** : c’est l’exigence ; le panier reste en mémoire (session).
- **Pas de `print()`** : erreurs typées `AppException`, textes via `AppStrings`, couleurs via `AppColors`.
