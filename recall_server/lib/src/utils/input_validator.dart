/// Helper for sanitizing and verifying user input
class InputValidator {
  
  /// Validate general text query (e.g. Chat, Search)
  /// - Max length check
  /// - HTML Tag stripping
  static String? validateQuery(String? query, {int maxLength = 500}) {
    if (query == null || query.trim().isEmpty) {
      return null;
    }

    if (query.length > maxLength) {
      throw const FormatException('Query exceeds maximum length');
    }

    // Basic sanitization: Remove HTML tags (script, etc.)
    // Note: This is a simple regex. For robust HTML protection, use a dedicated parser.
    // For this context, we just want to prevent obvious injection.
    String sanitized = query.replaceAll(RegExp(r'<[^>]*>'), '');
    
    return sanitized.trim();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
