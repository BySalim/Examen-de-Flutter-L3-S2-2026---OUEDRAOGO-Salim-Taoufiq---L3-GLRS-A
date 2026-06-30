class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;
  bool get isInsufficientFunds => statusCode == 422;

  @override
  String toString() => message;
}
