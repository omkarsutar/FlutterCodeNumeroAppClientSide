class RoleAwareMessageUtils {
  static String resolve({
    required bool isAdmin,
    required String simpleMessage,
    String? adminMessage,
    Object? error,
  }) {
    if (!isAdmin) return simpleMessage;

    final detailedMessage = adminMessage?.trim();
    if (detailedMessage != null && detailedMessage.isNotEmpty) {
      return detailedMessage;
    }

    final errorText = _normalize(error);
    if (errorText == null || errorText.isEmpty) {
      return simpleMessage;
    }

    return '$simpleMessage: $errorText';
  }

  static String? _normalize(Object? error) {
    if (error == null) return null;

    final text = error.toString().trim();
    if (text.isEmpty) return null;

    return text;
  }
}
