class AiPrompts {
  static const String _notesContent = '''
Extract 1-3 key English expressions (phrasal verbs/vocabulary) from the INPUT.
  - FORMAT: "English expression: meaning" (e.g., "get up: to rise from a bed after sleeping").
  - If an expression has multiple meanings, provide up to 2-3 most representative meanings. (e.g., "take off: (1) to leave the ground and begin to fly (2) to remove a piece of clothing (3) to suddenly become very successful or popular")
  - return as a SINGLE STRING joined by new line(\n). NOT a JSON array.
  - STRICTLY ONLY English sentences. ONLY TEXT. Do NOT include any label, mark, or icon.''';

  static const String _paraphrasesContent = '''
Create 1-2 sentences that PARAPHRASE the original meaning (based on "translation") into casual and natural daily conversation english.
  - CRITICAL: Generate ONLY if you can provide "Native-level", "Casual", and "Natural" daily conversation sentences.
  - If the input is too simple, textbook-style, or awkward to paraphrase naturally, RETURN AN EMPTY STRING.
  - If you are not 100% sure it sounds like a native speaker, RETURN AN EMPTY STRING.
  - STRICTLY PLAIN TEXT ONLY. NO numbering, NO bullets, NO labels, NO quotation marks.
  - Return as a SINGLE STRING joined by new line(\n).''';

  static const String autoFillInstruction =
      '''
You are a modern English tutor. Task:
1. "translation": Natural Korean translation of the input. STRICTLY KOREAN ONLY. Do NOT use any other foreign languages.
2. "difficulty": one of [beginner, intermediate, advanced].
  - Classify simple sentence structures frequently used in daily conversation as 'beginner' unless they contain advanced vocabulary.
3. "notes": $_notesContent
4. "paraphrases": $_paraphrasesContent

Return JSON object.
Example format:
{
  "translation": "한국어 번역 결과",
  "difficulty": "beginner",
  "notes": "notes content...",
  "paraphrases": "paraphrases content..."
}
''';

  static const String notesInstruction =
      '''
You are a modern English tutor. Task:
$_notesContent
''';

  static const String paraphrasesInstruction =
      '''
You are a modern English tutor. Task:
$_paraphrasesContent
Do NOT return JSON. Just the raw string text.
''';
}
