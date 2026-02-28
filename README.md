# Flutter Production Boilerplate

A robust, scalable Flutter boilerplate designed for production-grade applications.

## 🚀 Features

- **State Management**: [Riverpod](https://riverpod.dev/) (with Code Generation)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Architecture**: Feature-first, Clean Architecture (Data, Domain, Presentation)
- **Immutable Data**: [Freezed](https://pub.dev/packages/freezed) & [JsonSerializable](https://pub.dev/packages/json_serializable)
- **Localization**: Built-in `flutter_localizations` with ARB files
- **Environment Variables**: `flutter_dotenv` for secure API key management
- **Linting**: Strict lint rules for code quality
- **Theming**: Light & Dark mode support

## 📂 Structure

```
lib/
├── core/               # Shared modules (Router, Theme, Network, etc.)
├── features/           # Feature-based modules
│   └── home/
│       ├── data/       # Repositories, Data Sources
│       ├── domain/     # Entities, UseCases
│       └── presentation/ # Widgets, Providers
├── l10n/               # Localization files (.arb)
└── main.dart           # Entry point
```

## 📖 Documentation

The project documentation is organized in the `docs/` directory:

- **[Development](docs/development/)**: Technical guides and setup instructions.
  - [Flutter Guide](docs/development/FLUTTER.md)
  - [TDD & Process](docs/development/TDD.md)
  - [iOS Deployment Guide](docs/development/iOS_DEPLOYMENT_GUIDE.md)
- **[Design](docs/design/)**: Visual and UX specifications.
  - [UI Specification](docs/design/UI-SPEC.md)
- **[Project](docs/project/)**: Tracking and maintenance logs.
  - [Roadmap (TODO)](docs/project/TODO.md)
  - [Feedback & Ideas](docs/project/FEEDBACK.md)
- **[Notes](docs/notes/)**: Research, ideas, and general technical notes.
  - [AI Model Training (XGBoost)](docs/notes/XGBoost-Traning.md)

## 🛠️ Getting Started

1.  **Clone the repository**
    ```bash
    git clone https://github.com/jaeyp/flutter-bp.git
    cd flutter-bp
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    flutter gen-l10n
    ```

3.  **Setup Environment**
    Copy `.env.example` to `.env` and configure your variables.
    ```bash
    cp .env.example .env
    ```

4.  **Run Code Generation**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the App**
    ```bash
    flutter run
    ```

## 🔊 TTS Engine Selection

This project supports multiple on-device TTS engines. Select the desired engine in `.env`:

```env
# Available engines: supertonic2 | qwen3
TTS_ENGINE=supertonic2
```

### Available Engines

| Engine | Model Size | Sample Rate | Languages | Status |
|--------|-----------|-------------|-----------|--------|
| **supertonic2** | ~250 MB (4 ONNX files) | 24 kHz | en, ko, es, pt, fr | ✅ Ready |
| **qwen3** | TBD (INT8 quantized) | 24 kHz | en, zh, and more | ⏳ Pending model preparation |

### Building with Conditional Assets

To exclude unused engine assets from the app bundle, use the build script:

```bash
# Builds with only the selected engine's assets (reads TTS_ENGINE from .env)
./scripts/build.sh ios --release
./scripts/build.sh apk --release

# For development
./scripts/build.sh run
```

> **Note:** Running `flutter run` directly will include **both** engines' assets.
> Use `./scripts/build.sh run` for a lean build with only the selected engine.

### Preparing Qwen3 Model (INT8 Quantization)

Before using the Qwen3 engine, you must prepare the ONNX model:

```bash
# Install dependencies
pip install onnxruntime onnx optimum transformers torch

# Run quantization (outputs to assets/tts/qwen3/)
python scripts/quantize_qwen3.py

# Or quantize a pre-exported ONNX model
python scripts/quantize_qwen3.py --skip-export --onnx-input /path/to/qwen3.onnx
```

## 🧪 Testing

```bash
flutter test
```
