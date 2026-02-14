import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_surf/features/tts/domain/enums/tts_speaker.dart';
import 'package:english_surf/features/tts/service/tts_service.dart';

final studyModeTtsControllerProvider =
    Provider.autoDispose<StudyModeTtsController>((ref) {
      final ttsService = ref.read(ttsServiceProvider);

      // Register lifecycle hook: Stop TTS when this controller is disposed (screen closed)
      ref.onDispose(() {
        ttsService.stop();
      });

      return StudyModeTtsController(ref);
    });

class StudyModeTtsController {
  final Ref ref;

  StudyModeTtsController(this.ref);

  Future<void> play(String text, TtsSpeaker speaker, {String? language}) async {
    await ref.read(ttsServiceProvider).play(text, speaker, language: language);
  }

  Future<void> stop() async {
    await ref.read(ttsServiceProvider).stop();
  }
}
