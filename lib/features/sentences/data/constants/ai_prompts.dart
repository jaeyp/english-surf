class AiPrompts {
  static String _notesContent(String sourceLang, {String? notesLang}) {
    final meaningLang = notesLang ?? sourceLang;
    final isMonolingual = meaningLang == sourceLang;
    final meaningDirective = isMonolingual
        ? 'Explain meanings in $sourceLang (monolingual dictionary style).'
        : 'Write the definition/meaning part in $meaningLang (the $sourceLang expression itself stays in $sourceLang).';
    return '''
Extract 1-3 key $sourceLang expressions (phrasal verbs/vocabulary) from the INPUT.
  - FORMAT: "$sourceLang expression: meaning in $meaningLang"
  - $meaningDirective
  - If an expression has multiple meanings, provide up to 2-3 most representative meanings.
  - ONLY TEXT. Do NOT include any label, mark, or icon.''';
  }

  static String _paraphrasesContent(String sourceLang) =>
      '''
    Create 1-2 sentences that PARAPHRASE the original meaning (based on "translation") into casual and natural daily conversation $sourceLang.
  - CRITICAL: Paraphrases MUST be in $sourceLang ONLY. Do NOT use any other language for paraphrases.
  - Generate ONLY if you can provide "Native-level", "Casual", and "Natural" daily conversation sentences.
  - If the input is too simple, textbook-style, or awkward to paraphrase naturally, RETURN AN EMPTY ARRAY [].
  - If you are not 100% sure it sounds like a native speaker, RETURN AN EMPTY ARRAY [].
  - STRICTLY PLAIN TEXT ONLY. NO numbering, NO bullets, NO labels, NO quotation marks.
  - Return as a JSON LIST of strings (Array). e.g. ["paraphrase1", "paraphrase2"]''';

  static String autoFillInstruction({
    required String sourceLang,
    required String targetLang,
    String? notesLang,
  }) =>
      '''
You are a modern $sourceLang tutor. Task:
1. "translation": Natural $targetLang translation of the input. STRICTLY $targetLang ONLY. Do NOT use any other foreign languages.
2. "difficulty": one of [beginner, intermediate, advanced].
  - Classify simple sentence structures frequently used in daily conversation as 'beginner' unless they contain advanced vocabulary.
3. "notes": ${_notesContent(sourceLang, notesLang: notesLang)}
  - Return as a JSON LIST of strings (Array). e.g. ["note1", "note2"]
4. "paraphrases": [IMPORTANT: paraphrases are ALWAYS in $sourceLang, regardless of the notes language above.]
  ${_paraphrasesContent(sourceLang)}

Return JSON object.
Example format:
{
  "translation": "$targetLang translation",
  "difficulty": "beginner",
  "notes": [
    "expression1: meaning...",
    "expression2: meaning..."
  ],
  "paraphrases": [
    "($sourceLang sentence 1)",
    "($sourceLang sentence 2)"
  ]
}
''';

  static String notesInstruction({
    required String sourceLang,
    String? notesLang,
  }) =>
      '''
You are a modern $sourceLang tutor. Task:
${_notesContent(sourceLang, notesLang: notesLang)}

Return a JSON Object with a "notes" field containing a List of strings.
Example:
{
  "notes": [
    "expression1: meaning...",
    "expression2: meaning..."
  ]
}
''';

  static String paraphrasesInstruction({required String sourceLang}) =>
      '''
You are a modern $sourceLang tutor. Task:
${_paraphrasesContent(sourceLang)}

Return a JSON Object with a "paraphrases" field containing a List of strings.
Example:
{
  "paraphrases": [
    "paraphrase1",
    "paraphrase2"
  ]
}
''';

  static String autoFillInstructionNoTranslation({
    required String sourceLang,
    String? notesLang,
  }) =>
      '''
You are a modern $sourceLang tutor. Task:
1. "difficulty": one of [beginner, intermediate, advanced].
2. "notes": ${_notesContent(sourceLang, notesLang: notesLang)}
  - Return as a JSON LIST of strings (Array). e.g. ["note1", "note2"]
3. "paraphrases": ${_paraphrasesContent(sourceLang)}

Return JSON object.
Example format:
{
  "difficulty": "beginner",
  "notes": [
    "expression1: meaning...",
    "expression2: meaning..."
  ],
  "paraphrases": [
    "paraphrase1",
    "paraphrase2"
  ]
}
''';

  static String reverseGenInstruction({
    required String sourceLang,
    required String targetLang,
  }) =>
      '''
You are a native $sourceLang speaker.
Task: Create a "Native-level", "Casual", and "Natural" daily conversation $sourceLang sentence that conveys the meaning of the given $targetLang Input.
  - The $sourceLang sentence must correspond to the $targetLang meaning.
  - Use modern, conversational $sourceLang (not textbook style).
  - STRICTLY return ONLY the $sourceLang sentence string.
  - Do NOT include any explanations, labels, or JSON.
  - Do NOT surround the output with quotation marks.
''';
}
