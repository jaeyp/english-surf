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

## 🧪 Testing

```bash
flutter test
```
