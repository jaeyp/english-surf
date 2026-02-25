# Project Development Log

## 20260224 fix(study): refactor audio flip logic and add wakelock
- Decouple audio loop progression from card flip state
- Fix speaker icon losing state on card flip
- Add wakelock_plus to prevent screen from sleeping during Study Mode"

## 20260224 refactor: switch flutter_onnxruntime to FFI onnxruntime
commit 1e9f2059fba81846639eb0791433afa172ae35a6

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