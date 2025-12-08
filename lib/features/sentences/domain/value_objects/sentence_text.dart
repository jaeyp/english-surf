import 'package:freezed_annotation/freezed_annotation.dart';
import 'text_range.dart';

part 'sentence_text.freezed.dart';
part 'sentence_text.g.dart';

/// Value object representing formatted sentence text.
/// 
/// Encapsulates the raw text with markup syntax and parsed styling information.
/// Supports two types of text styling:
/// - Bold: `**text**`
/// - Highlight: `|text|`
/// - Both: `|**text**|`
@freezed
class SentenceText with _$SentenceText {
  const factory SentenceText({
    /// Original text with markup syntax (e.g., "|**give and go**|")
    required String rawText,
    
    /// Plain text with all markup removed (e.g., "give and go")
    required String plainText,
    
    /// List of text ranges that should be rendered in bold
    @Default([]) List<TextRange> boldRanges,
    
    /// List of text ranges that should be highlighted
    @Default([]) List<TextRange> highlightRanges,
  }) = _SentenceText;

  factory SentenceText.fromJson(Map<String, dynamic> json) =>
      _$SentenceTextFromJson(json);

  /// Creates a SentenceText by parsing raw text with markup syntax.
  /// 
  /// Parsing rules:
  /// - `**text**` → bold
  /// - `|text|` → highlight
  /// - `|**text**|` → bold + highlight
  factory SentenceText.parse(String rawText) {
    final boldRanges = <TextRange>[];
    final highlightRanges = <TextRange>[];
    final plainTextBuffer = StringBuffer();
    
    int currentPos = 0;
    int plainTextPos = 0;
    
    while (currentPos < rawText.length) {
      // Check for highlight start |
      if (rawText[currentPos] == '|') {
        final highlightEnd = rawText.indexOf('|', currentPos + 1);
        if (highlightEnd == -1) {
          // No closing |, treat as normal text
          plainTextBuffer.write('|');
          currentPos++;
          plainTextPos++;
          continue;
        }
        
        // Extract content between |...|
        final content = rawText.substring(currentPos + 1, highlightEnd);
        
        // Check if content has bold markers
        bool hasBold = false;
        String actualText = content;
        
        if (content.startsWith('**') && content.endsWith('**') && content.length > 4) {
          hasBold = true;
          actualText = content.substring(2, content.length - 2);
        }
        
        final startPos = plainTextPos;
        final endPos = plainTextPos + actualText.length;
        
        // Add ranges
        highlightRanges.add(TextRange(start: startPos, end: endPos));
        if (hasBold) {
          boldRanges.add(TextRange(start: startPos, end: endPos));
        }
        
        plainTextBuffer.write(actualText);
        plainTextPos += actualText.length;
        currentPos = highlightEnd + 1;
      }
      // Check for standalone bold **text**
      else if (currentPos < rawText.length - 1 && 
               rawText.substring(currentPos, currentPos + 2) == '**') {
        final boldEnd = rawText.indexOf('**', currentPos + 2);
        if (boldEnd == -1) {
          // No closing **, treat as normal text
          plainTextBuffer.write('**');
          currentPos += 2;
          plainTextPos += 2;
          continue;
        }
        
        final boldText = rawText.substring(currentPos + 2, boldEnd);
        final startPos = plainTextPos;
        final endPos = plainTextPos + boldText.length;
        
        boldRanges.add(TextRange(start: startPos, end: endPos));
        
        plainTextBuffer.write(boldText);
        plainTextPos += boldText.length;
        currentPos = boldEnd + 2;
      }
      // Regular character
      else {
        plainTextBuffer.write(rawText[currentPos]);
        currentPos++;
        plainTextPos++;
      }
    }
    
    return SentenceText(
      rawText: rawText,
      plainText: plainTextBuffer.toString(),
      boldRanges: boldRanges,
      highlightRanges: highlightRanges,
    );
  }
}
