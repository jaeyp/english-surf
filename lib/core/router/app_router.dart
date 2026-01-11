import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/sentences/presentation/screens/sentence_list_screen.dart';
import '../../features/sentences/presentation/screens/sentence_edit_screen.dart';
import '../../features/study/presentation/screens/study_mode_screen.dart';
import '../../features/ocr/presentation/screens/camera_ocr_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/study/presentation/arguments/study_mode_arguments.dart';
import '../../features/sentences/domain/entities/sentence.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/sentences',
        builder: (context, state) => const SentenceListScreen(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final extra = state.extra;
          final sentence = extra is Sentence ? extra : null;
          final initialText = extra is String ? extra : null;
          return SentenceEditScreen(
            sentence: sentence,
            initialOriginalText: initialText,
          );
        },
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraOCRScreen(),
      ),
      GoRoute(
        path: '/study',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is StudyModeArguments
              ? extra
              : StudyModeArguments(initialIndex: extra is int ? extra : 0);
          return StudyModeScreen(
            initialIndex: args.initialIndex,
            isTestMode: args.isTestMode,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
