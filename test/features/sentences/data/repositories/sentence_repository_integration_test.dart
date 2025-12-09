import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Integration Test: Should load sentences from actual JSON file', (
    tester,
  ) async {
    // 1. ProviderContainer 생성
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // 2. Repository 가져오기
    final repository = container.read(sentenceRepositoryProvider);

    // 3. 실제 데이터 로드
    final sentences = await repository.getAllSentences();

    // 4. 검증
    expect(sentences, isNotEmpty);
    // 데이터 개수가 133개인지 확인 (JSON 파일에 따라 다를 수 있음)
    print('Total sentences loaded: ${sentences.length}');

    // 첫 번째 데이터 확인
    final firstSentence = sentences.first;
    print('First Sentence ID: ${firstSentence.id}');
    print('First Sentence Text: ${firstSentence.original.text}');

    expect(firstSentence.id, 1);
    expect(firstSentence.original.text, isNotEmpty);
  });
}
