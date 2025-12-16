# English Surf Implementation Plan

## 🚨 Project Rules (MUST FOLLOW)
1. **No Korean Comments**: All comments in the source code MUST be in English.
2. **English Only in Code**: Variable names, string literals (unless for UI display), and documentation must be in English.
3. **TDD**: Always write tests for new features.


## 🎯 Project Goal
English sentence learning app with rich text styling and flashcard features.

## 📊 Current Status
- **Phase 1: Domain & Data Modeling** (✅ Completed)
- **Phase 2: Data Layer Implementation** (🚧 In Progress)
- **Phase 3: Application Layer (State Management)** (⏳ Pending)
- **Phase 4: Presentation Layer (UI)** (⏳ Pending)

---

## ✅ Phase 1: Domain & Data Modeling (Completed)
- [x] **Entity Design:**
    - `Sentence` entity with `original` (SentenceText), `translation` (String), `difficulty` (Enum).
    - `SentenceText` value object supporting rich styling (`text` + `styles` list).
    - `TextStyle` value object for extensible styling (bold, highlight, color, etc.).
- [x] **Data Migration:**
    - Migrated `sentences.json` from legacy markup string to structured JSON object.
    - Field renaming: `sentence` -> `original`.
    - Removed all legacy markup (`**`, `|`) from data.
- [x] **Validation:**
    - Verified data integrity for all 133 sentences.
    - Ensured unique IDs and Orders.

---

## ✅ Phase 2: Data Layer Implementation (Completed)
- [x] **Local Data Source:**
    - Implement `SentenceLocalDataSource` to read `assets/data/sentences.json`.
    - Handle JSON parsing and error cases.
- [x] **Repository Implementation:**
    - Implement `SentenceRepositoryImpl` implementing `SentenceRepository` interface.
    - Implemented `getAllSentences` and `getSentenceById`.
    - *Note: `add`, `update`, `delete` are postponed to Phase 5 as they require local storage implementation.*
- [x] **Testing:**
    - Verify data loading with basic unit tests and main.dart integration check.

---

## ✅ Phase 3: Application Layer (State Management) [Completed]
- [x] **Providers Setup**
  - [x] `SentenceList` (AsyncNotifier): Fetch & Cache data
  - [x] `SentenceFilter` (Notifier): Manage filter state (Difficulty, SortType)
  - [x] `FilteredSentences` (Provider): Combine List & Filter logic

## Phase 4: Presentation Layer (UI Implementation)
- [x] **Common Widgets**
    - [x] `SentenceTextView`: Rich text rendering (Bold, Highlight)
    - [x] `SentenceListItem`: List item UI with Swipe-to-Action (Delete, Edit) & Language Mode
    - [x] `SentenceFilterBar`: Filter chips (Sort, Difficulty)
    - [x] `SentenceCard`: 3D Flip animation, Front/Back view (Notes/Examples support)
- [x] **Screens**
    - [x] `SentenceListScreen`: Main list view, SliverAppBar, FilterBar, FAB, Language Toggle (Icon)
    - [x] `StudyModeScreen`: Full-screen card view (PageView), Navigation (Swipe only)
    - [ ] `SentenceEditScreen`: Add/Edit sentence form, Rich text input, Floating Context Menu
- [x] **State Management Integration**
    - [x] Connect Providers to Screens
    - [x] Implement Filter/Sort logic in UI
    - [x] Implement Language Mode (Orig↔Trans) logic

## Phase 5: Advanced Input & AI Integration (Next Step)

### 1. New Sentence Addition Methods (Input)
- [ ] **Method A: Manual Entry**
    - [ ] Standard text input form in `SentenceEditScreen`.
- [ ] **Method B: Camera OCR (Live Text)**
    - [ ] Integrate `google_mlkit_text_recognition` or `flutter_scalable_ocr`.
    - [ ] Implement Live Camera View with text detection overlay.
    - [ ] Workflow: Capture Video/Frame -> Extract Text -> Paste to New Card -> Open Edit Screen.
- [ ] **Method C: Gallery Image OCR**
    - [ ] Integrate `image_picker` for gallery access.
    - [ ] Perform OCR on selected image.
    - [ ] Workflow: Select Image -> Extract Text -> Paste to New Card -> Open Edit Screen.

### 2. Back Content Generation (AI Auto-Fill)
- [ ] **Method A: Manual Entry**
    - [ ] Input fields for Translation, Notes, and Examples.
- [ ] **Method B: AI Auto-Generation**
    - [ ] **AI Service Setup**: Integrate Gemini API (or similar LLM).
    - [ ] **Prompt Engineering**: Create prompts to generate:
        - Natural Translation (Korean).
        - Key Grammar/Vocabulary Notes.
        - 3 Practical Example Sentences.
    - [ ] **UI Integration**:
        - Add "✨ Auto-Fill with AI" button in `SentenceEditScreen`.
        - Show loading state while generating.
        - Allow user to review and edit generated content before saving.

### 3. Data Persistence (Local DB)
- [ ] **Database Setup**: Implement `Drift` (SQLite) or `Hive` for local storage.
- [ ] **CRUD Operations**: Create, Read, Update, Delete sentences locally.
- [ ] **Repository Update**: Replace dummy data repository with local DB repository.

### 4. User Onboarding (Tutorial)
- [ ] **Coach Mark Overlay**
    - [ ] Integrate `tutorial_coach_mark` package.
    - [ ] **Design**: Use "Hand-drawn" style assets (arrows, circles) & Handwriting Font.
    - [ ] **Logic**: Implement First-run check (Show only once per screen using `SharedPreferences`).
    - [ ] **Scenarios**:
        - `SentenceListScreen`: Explain Swipe actions (Edit/Delete), Filter chips, Language toggle.
        - `StudyModeScreen`: Explain Tap to Flip, Swipe to Navigate.
        - `SentenceEditScreen`: Explain AI Auto-fill, OCR options, Text Styling.

## Phase 6: Monetization & Deployment (Launch Ready)

### 1. Monetization (Revenue)
- [ ] **AdMob Integration**
    - [ ] Setup AdMob Account & App IDs.
    - [ ] Implement **Banner Ad** at the bottom of `SentenceListScreen` & `StudyModeScreen`.
    - [ ] Handle Ad loading/error states gracefully.
- [ ] **In-App Purchases (IAP)**
    - [ ] Integrate `in_app_purchase` package.
    - [ ] Create "Pro Version" product (Non-consumable).
    - [ ] Features: **Remove Ads**, **Unlimited Offline Usage** (No internet check required).
    - [ ] Implement Purchase Restore functionality.

### 2. Store Deployment (Release)
- [ ] **App Store (iOS) Prep**
    - [ ] Configure `Info.plist` (Permissions, Ad tracking usage description).
    - [ ] Create App Icons & Launch Screens.
    - [ ] Generate Screenshots & App Description.
- [ ] **Play Store (Android) Prep**
    - [ ] Configure `AndroidManifest.xml`.
    - [ ] Sign the App (Keystore generation).
    - [ ] Generate Screenshots & Feature Graphic.
- [ ] **Compliance**
    - [ ] Add Privacy Policy link.
    - [ ] Add Terms of Service.

---

## 📝 Notes & Decisions
- **Styling:** Moved away from markdown parsing (`**`, `|`) to a robust range-based JSON structure for better extensibility.
- **Localization:** Multi-language support (`translations.ko`) is postponed. Using a single `translation` field for now.
- **Data Field:** Renamed `sentence` to `original` to clarify it represents the source text.
