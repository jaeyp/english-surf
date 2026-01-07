enum AiProvider {
  google,
  groq;

  String get displayName {
    switch (this) {
      case AiProvider.google:
        return 'Google AI';
      case AiProvider.groq:
        return 'Groq AI';
    }
  }

  String get defaultModel {
    switch (this) {
      case AiProvider.google:
        return 'gemini-2.5-flash-lite';
      case AiProvider.groq:
        return 'llama-3.1-8b-instant';
    }
  }

  List<String> get availableModels {
    switch (this) {
      case AiProvider.google:
        return ['gemini-2.5-flash-lite', 'gemini-2.5-flash'];
      case AiProvider.groq:
        return [
          'llama-3.1-8b-instant',
          'llama-3.3-70b-versatile',
          'meta-llama/llama-4-maverick-17b-128e-instruct',
          'meta-llama/llama-4-scout-17b-16e-instruct',
        ];
    }
  }

  // Helper method to look up enum from string
  static AiProvider fromString(String? key) {
    if (key == null) return AiProvider.groq; // Default to Groq as requested
    try {
      return AiProvider.values.firstWhere((e) => e.name == key);
    } catch (_) {
      return AiProvider.groq;
    }
  }
}
