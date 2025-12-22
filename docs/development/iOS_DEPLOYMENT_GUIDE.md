# iOS Deployment Command Summary (2025-12-21)

어제 실물 아이폰에서 앱을 구동하기 위해 실행했던 모든 주요 커맨드들을 시스템 환경 설정부터 실행까지 순서대로 정리했습니다.

## 🛠 0. 개발 환경 구성 (Homebrew & OS 설정)
Flutter 및 앱 빌드에 필요한 도구들을 설치하고 시스템 경로를 설정하는 단계입니다.

```bash
# 1. Homebrew 설치 (패키지 관리자)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 쉘 환경 변수 등록 (Apple Silicon Mac 대응)
# .zprofile에 brew 경로를 추가하여 터미널 어디서든 brew 명령어를 사용하게 합니다.
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/rururue/.zprofile

# 3. 현재 터미널 세션에 즉시 적용
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. 설치 확인
brew --version
```
*   **실행 이유**: Mac에서 CocoaPods나 기타 개발 도구를 관리하기 위해 가장 먼저 필요한 과정입니다. `echo`와 `eval`은 설치된 Homebrew를 시스템이 인식하도록 등록하기 위해 실행되었습니다.

## 🚀 필수 빌드 및 실행 커맨드

### 1. 환경 및 설정 확인
```bash
xcode-select -p
```
*   **실행 이유**: 현재 시스템에서 Flutter가 참조하고 있는 Xcode 개발자 도구의 경로가 올바른지 확인합니다.

### 2. Xcode 프로젝트 열기 및 서명 설정
```bash
open ios/Runner.xcworkspace
```
*   **실행 이유**: 실물 아이폰 설치에 필수적인 **Apple ID 서명(Signing)** 설정을 위해 Xcode를 실행했습니다.

### 3. 연결된 장치 식별
```bash
flutter devices
```
*   **실행 이유**: 연결된 아이폰의 **장치 ID(Device ID)**를 확인하여 특정 장치에 앱을 설치하기 위해 필요합니다.

### 4. 앱 빌드 및 실행
```bash
flutter run -d [DEVICE_ID] --release
```
*   **실행 이유**: 실제 장치에 최적화된 `--release` 모드로 앱을 설치하고 실행합니다.

---

## 🧹 빌드 클린업 및 CocoaPods 관리
의존성 충돌이나 빌드 오류 발생 시 실행했던 해결 방법들입니다.

```bash
# 1. Flutter 캐시 삭제 및 의존성 재설치
flutter clean
flutter pub get

# 2. iOS 라이브러리(CocoaPods) 초기화
# Pods 폴더와 Lock 파일을 삭제하여 라이브러리 간의 충돌을 해결합니다.
rm -rf ios/Pods ios/Podfile.lock
```

> [!TIP]
> `echo`와 `eval`을 통해 `.zprofile`을 수정한 것은 Mac을 재시작하거나 새 터미널을 열어도 개발 도구들이 항상 정상 작동하게 하기 위한 매우 중요한 설정이었습니다.
