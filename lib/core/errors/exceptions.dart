class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class InsufficientWalletException implements Exception {
  final String message;
  InsufficientWalletException(this.message);

  @override
  String toString() => message;
}
