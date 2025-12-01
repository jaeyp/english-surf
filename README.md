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
