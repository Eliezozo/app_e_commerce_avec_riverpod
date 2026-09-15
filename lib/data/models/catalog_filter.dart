enum ProductSort { nameAsc, priceAsc, priceDesc, ratingDesc }

class CatalogFilter {
  const CatalogFilter({
    this.category,
    this.query = '',
    this.sort = ProductSort.nameAsc,
  });

  final String? category;
  final String query;
  final ProductSort sort;

  CatalogFilter copyWith({
    String? category,
    bool clearCategory = false,
    String? query,
    ProductSort? sort,
  }) {
    return CatalogFilter(
      category: clearCategory ? null : (category ?? this.category),
      query: query ?? this.query,
      sort: sort ?? this.sort,
    );
  }
}
