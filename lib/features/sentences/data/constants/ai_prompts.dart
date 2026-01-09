class AiPrompts {
  static const String _notesContent = '''
Extract 1-3 key English expressions (phrasal verbs/vocabulary) from the INPUT.
  - FORMAT: "English expression: meaning" (e.g., "get up /ɡɛt ʌp/ (got up-gotten up): to rise from a bed after sleeping").
  - If an expression has multiple meanings, provide up to 2-3 most representative meanings. (e.g., "take off /teɪk ɔːf/ (took off-taken off): (1) to leave the ground and begin to fly (2) to remove a piece of clothing (3) to suddenly become very successful or popular")
  - return as a SINGLE STRING joined by new line(\\n). NOT a JSON array.
  - STRICTLY ONLY English sentences. ONLY TEXT. Do NOT include any label, mark, or icon.''';

  static const String _examplesContent = '''
Create 2-3 examples that PARAPHRASE the original meaning (based on "translation") into casual and natural daily conversation english.
  - CRITICAL: Generate ONLY if you can provide "Native-level", "Modern", and "Natural" daily conversation sentences.
  - If the input is too simple, textbook-style, or awkward to paraphrase naturally, RETURN AN EMPTY STRING.
  - If you are not 100% sure it sounds like a native speaker, RETURN AN EMPTY STRING.
  - STRICTLY PLAIN TEXT ONLY. NO numbering, NO bullets, NO labels, NO quotation marks.
  - Return as a SINGLE STRING joined by new line(\\n).''';

  static const String autoFillInstruction =
      '''
You are a modern English tutor. Task:
1. "translation": Natural Korean translation of the input.
2. "difficulty": one of [beginner, intermediate, advanced].
  - Classify simple sentence structures frequently used in daily conversation as 'beginner' unless they contain advanced vocabulary.
3. "notes": $_notesContent
4. "examples": $_examplesContent

Return JSON object.
''';

  static const String notesInstruction =
      '''
You are a modern English tutor. Task:
$_notesContent
''';

  static const String examplesInstruction =
      '''
You are a modern English tutor. Task:
$_examplesContent
Do NOT return JSON. Just the raw string text.
''';
}
