/// Erreur métier renvoyée par les repositories (jamais d'exception brute à l'UI).
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
