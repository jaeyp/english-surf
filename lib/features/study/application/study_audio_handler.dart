import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StudyAudioCommand {
  play,
  pause,
  skipToNext,
  skipToPrevious,
  toggleShuffle,
  toggleRepeat,
}

class StudyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _commandController = StreamController<StudyAudioCommand>.broadcast();
  Stream<StudyAudioCommand> get commands => _commandController.stream;

  final Uri? artUri;

  StudyAudioHandler({this.artUri}) {
    _initAudioSession();
    // Broadcast initial state
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: false,
      ),
    );
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Listen for interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            pause();
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
            break;
        }
      }
    });
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
  }

  void updatePlaybackState({
    bool? playing,
    AudioProcessingState? processingState,
    AudioServiceRepeatMode? repeatMode,
    AudioServiceShuffleMode? shuffleMode,
  }) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing == true ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        playing: playing ?? playbackState.value.playing,
        processingState: processingState ?? playbackState.value.processingState,
        repeatMode: repeatMode ?? playbackState.value.repeatMode,
        shuffleMode: shuffleMode ?? playbackState.value.shuffleMode,
      ),
    );
  }

  @override
  Future<void> play() async {
    final session = await AudioSession.instance;
    await session.setActive(true);
    _commandController.add(StudyAudioCommand.play);
    updatePlaybackState(playing: true);
  }

  @override
  Future<void> pause() async {
    _commandController.add(StudyAudioCommand.pause);
    updatePlaybackState(playing: false);
  }

  @override
  Future<void> stop() async {
    _commandController.add(StudyAudioCommand.pause);
    updatePlaybackState(
      playing: false,
      processingState: AudioProcessingState.idle,
    );
    final session = await AudioSession.instance;
    await session.setActive(false);
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    _commandController.add(StudyAudioCommand.skipToNext);
  }

  @override
  Future<void> skipToPrevious() async {
    _commandController.add(StudyAudioCommand.skipToPrevious);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _commandController.add(StudyAudioCommand.toggleShuffle);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _commandController.add(StudyAudioCommand.toggleRepeat);
  }
}

final studyAudioHandlerProvider = Provider<StudyAudioHandler>((ref) {
  throw UnimplementedError('Initialized in main');
});
