import 'package:flutter_test/flutter_test.dart';
import '../../../../../lib/features/sentences/domain/enums/app_language.dart';

void main() {
  group('AppLanguage.detect', () {
    test('returns null for empty text', () {
      expect(AppLanguage.detect(''), isNull);
    });

    test('returns korean for hangul characters', () {
      expect(AppLanguage.detect('안녕하세요'), AppLanguage.korean);
      expect(
        AppLanguage.detect('Hello 안녕하세요'),
        AppLanguage.korean,
      ); // Mixed prioritizes Korean
    });

    test('returns spanish for unique spanish characters', () {
      expect(AppLanguage.detect('¿Cómo estás?'), AppLanguage.spanish);
      expect(AppLanguage.detect('¡Hola!'), AppLanguage.spanish);
      expect(AppLanguage.detect('mañana'), AppLanguage.spanish); // ñ
    });

    test('returns portuguese for unique portuguese characters', () {
      expect(AppLanguage.detect('coração'), AppLanguage.portuguese); // ç, ã
      expect(AppLanguage.detect('nações'), AppLanguage.portuguese); // õ
    });

    test('returns french for unique french features', () {
      expect(
        AppLanguage.detect('français'),
        AppLanguage.french,
      ); // ç (shared but weighted)
      expect(
        AppLanguage.detect('être'),
        AppLanguage.french,
      ); // ê (shared but weighted)
      expect(
        AppLanguage.detect('où aller à la plage'),
        AppLanguage.french,
      ); // à, ù
    });

    test('distinguishes similar latin languages based on score', () {
      // Spanish vs Portuguese
      // 'información' (ES) vs 'informação' (PT)
      expect(
        AppLanguage.detect('información'),
        AppLanguage.spanish,
      ); // ó -> ES+5
      expect(
        AppLanguage.detect('informação'),
        AppLanguage.portuguese,
      ); // ç -> PT+2, ã -> PT+7

      // French vs Portuguese (both have ç, ê)
      // 'garçon' (FR) - just ç -> FR+2, PT+2. Tie?
      // Wait, 'ç' gives +2 to PT and +2 to FR.
      // If tie, map iteration order matters. map keys: ES, PT, FR.
      // Spanish=0, Portuguese=2, French=2. Reduce logic: a.value > b.value ? a : b.
      // 2 > 2 is false, so it takes b (French). so 'garçon' -> French.
      expect(AppLanguage.detect('garçon'), AppLanguage.french);

      // 'você' (PT) - ê -> PT+7
      // ê is not in my French regex list: [àèùâîôûëï]. So only PT gets points.
      expect(AppLanguage.detect('você'), AppLanguage.portuguese);
    });

    test('defaults to english for plain latin text', () {
      expect(AppLanguage.detect('Hello world'), AppLanguage.english);
      expect(
        AppLanguage.detect('Lorem ipsum dolor sit amet'),
        AppLanguage.english,
      );
    });

    test('returns null for unsupported scripts', () {
      expect(AppLanguage.detect('你好世界'), isNull); // Chinese
      expect(AppLanguage.detect('こんにちは'), isNull); // Japanese
      expect(AppLanguage.detect('مرحبا'), isNull); // Arabic
      expect(AppLanguage.detect('12345'), isNull); // Numbers only
    });
  });
}
