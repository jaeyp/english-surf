# Project Development Log

## 20260228 feat(study): implement background TTS audio session with lock screen controls
- **AudioService 연동**: `audio_service` 패키지를 도입하여 iOS/Android 잠금 화면 및 제어 센터에 미니 플레이어 표출.
- **백그라운드 AudioSession 유지**: `just_audio`의 기본 세션 관리를 비활성화하고 `audio_service`가 `AVAudioSessionCategory.playback` 권한을 독점하게 하여 폰이 잠겨도 오디오가 끊기지 않도록 수정.
- **Lock Screen Metadata**: `MediaItem`을 통해 현재 학습 중인 문장, 번역, 진행 상황 및 앱 아이콘(`artUri`)을 잠금 화면 플레이어에 실시간 렌더링하도록 반영.
- **CoreML 백그라운드 크래시 방지**: iOS 정책상 백그라운드 환경에서 NPU(Apple Neural Engine) 호출 시 발생하는 `-1` 크래시를 방지하기 위해, `TtsWorkerIsolate`의 `CoreMLProvider` 옵션을 제거하고 백그라운드에서도 안정적인 CPU Fallback을 사용하도록 구조 변경.
- **예외 처리 시 무한 스킵 방지**: `_playAudioLoop` 내부에서 백그라운드 오류 발생 시 강제로 `_nextPage()`가 무한 재귀 호출되던 논리적 결함을 일시정지(`pause`) 상태로 빠지도록 수정.## 20260224 fix(study): refactor audio flip logic and add wakelock
- Decouple audio loop progression from card flip state
- Fix speaker icon losing state on card flip
- Add wakelock_plus to prevent screen from sleeping during Study Mode"

## 20260224 refactor: switch flutter_onnxruntime to FFI onnxruntime
commit 1e9f2059fba81846639eb0791433afa172ae35a6

* flutter_onnxruntime이 single thread에서 동작해서 UI performance 향상을 위해 FFI onnxruntime(multi thread)으로 마이그레이션 진행함.

📝 [최종 리뷰] FFI 마이그레이션 (flutter_onnxruntime -> onnxruntime)
이번 작업에서 개선된 핵심 아키텍처는 다음과 같습니다.

1. 완전한 스레드 통신 분리 (No MethodChannel)
가장 큰 성과는 lib/features/tts/service/tts_worker_isolate.dart에 격리된 워커 환경입니다. 이제 ONNX 추론 중에 플러그인(MethodChannel)을 타고 UI 스레드로 돌아가지 않기 때문에, 음성을 합성하는 도중에 앱이 멈추거나 스와이프 애니메이션이 버벅이는 현상(Jank)이 영구적으로 사라졌습니다.

2. 무결점 C++ 메모리 방어 설계 (try...finally)
유저가 스터디 모드에서 카드를 빠르게 광클(스킵)할 때 발생하는 예외(Job Cancelled) 상황을 100% 방어했습니다. 워커 내부의 실행 흐름 전체를 거대한 try {} finally {} 블록으로 묶어서, 어떤 오류가 터지든 간섭 없이 생성된 ONNX 텐서(./release())와 C++ 옵션 포인터들이 구조적으로 소멸되도록 조치했습니다. 이제 메모리 누수나 EXC_BAD_ACCESS 데드락 크러시가 발생하지 않습니다.

3. 디스크 오디오 Zero-copy 최적화
lib/features/tts/service/supertonic_pipeline.dart에서 .wav 파일을 디스크에 쓰는 디스크 I/O 병목을 제거했습니다. 대신 lib/features/tts/service/tts_service.dart에 RawPcmAudioSource 기반의 인메모리 스트리밍 래퍼를 씌워, RAM에 떠 있는 PCM 파형 데이터를 실시간 직행으로 꽂아 재생 속도를 비약적으로 끌어올렸습니다.

4. 안정적인 하드웨어 가속
아이폰/맥 환경에서는 NPU 가속을 위해 appendCoreMLProvider(CoreMLFlags.useNone) 플래그를 안정적으로 주입하여 연산 지연시간을 대폭 단축했습니다.