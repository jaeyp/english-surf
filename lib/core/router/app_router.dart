import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sentences/presentation/screens/sentence_list_screen.dart';
import '../../features/sentences/presentation/screens/sentence_edit_screen.dart';
import '../../features/sentences/presentation/screens/study_mode_screen.dart';
import '../../features/sentences/domain/entities/sentence.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SentenceListScreen(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final sentence = state.extra as Sentence?;
          return SentenceEditScreen(sentence: sentence);
        },
      ),
      GoRoute(
        path: '/study',
        builder: (context, state) {
          final initialIndex = state.extra as int? ?? 0;
          return StudyModeScreen(initialIndex: initialIndex);
        },
      ),
    ],
  );
}
