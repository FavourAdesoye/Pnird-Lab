class AppException implements Exception {
  final String message;
  final String? debugDetails;

  const AppException(this.message, {this.debugDetails});

  @override
  String toString() => message;
}
