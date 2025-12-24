# English Surf Implementation Plan

## 🚨 Project Rules (MUST FOLLOW)
1. **No Korean Comments**: All comments in the source code MUST be in English.
2. **English Only in Code**: Variable names, string literals (unless for UI display), and documentation must be in English.
3. **TDD**: Always write tests for new features.


## 🎯 Project Goal
English sentence learning app with rich text styling and flashcard features.

## 📊 Current Status
- **Phase 1: Domain & Data Modeling** (✅ Completed)
- **Phase 2: Data Layer Implementation** (✅ Completed)
- **Phase 3: Application Layer (State Management)** (✅ Completed)
- **Phase 4: Presentation Layer (UI)** (✅ Completed)
- **Phase 4.1: Polishing & Hardening** (🚧 In Progress - Polishing Done)
- Phase 5: Advanced Input & AI Integration (🚧 In Progress)
- **Phase 6: Monetization & Deployment** - Launch Ready (⏳ Pending)

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
    - [x] `SentenceEditScreen`: Add/Edit sentence form, Rich text input, Floating Context Menu
- [x] **State Management Integration**
    - [x] Connect Providers to Screens
    - [x] Implement Filter/Sort logic in UI
    - [x] Implement Language Mode (Orig↔Trans) logic
- [x] **Data Persistence (Local DB)**
    - [x] **Database Setup**: Implement `Drift` (SQLite) or `Hive` for local storage.
    - [x] **CRUD Operations**: Create, Read, Update, Delete sentences locally.
    - [x] **Repository Update**: Replace dummy data repository with local DB repository.

## Phase 4.1: Polishing & Hardening (Refinement)
- [x] **UI/UX Polishing**
    - [x] **Empty States**: Create beautiful "No Data" views for Empty List and No Filter Results.
    - [x] **Search Bar**: Add real-time search functionality to the `SentenceListScreen`.
    - [x] **Haptic Feedback**: Add subtle haptics for significant interactions (swipe, card flip, save).
    - [x] **Accessibility (a11y)**: Ensure screen reader support and proper contrast ratios.
- [x] **Editor Experience (UX)**
    - [x] **Markup UX**: Improve text selection and cursor handling when applying bold/highlight.
    - [x] **Validation Feedback**: Better UI feedback for form validation (e.g., shaking animation or clearer error text).
- [x] **Animations & Transitions**
    - [x] **Smooth Transitions**: Enhance list animations (e.g., using `AnimatedList` for deletions).
    - [x] **Loading Shimmer**: Add a loading state/shimmer while DB is initializing.

## Phase 5: Advanced Input & AI Integration (Next Step)

### 1. New Sentence Addition Methods (Input)
- [ ] **Method A: Manual Entry**
    - [x] Standard text input form in `SentenceEditScreen`.
- [x] **Method B: Camera OCR (Live Text)**
    - [x] Add dependencies & Permissions.
    - [x] **Live Overlay Implementation**:
        - [x] Create `TextRecognizerPainter` for bounding boxes (AR Bubbles implemented).
        - [x] Implement `CoordinatesTranslator` utility.
        - [x] Update `CameraOCRScreen` to use `startImageStream` (with 1s throttling).
        - [x] Implement Tap-to-Select logic.
    - [x] **Post-processing Intelligence** (`OcrProcessor`):
        - [x] Filter short noise (< 10 chars).
        - [x] Merge vertically adjacent text blocks into paragraphs.
        - [x] Punctuation-aware paragraph detection (`.`, `!`, `?`, `"`, `'` break merging).
        - [x] Normalize whitespace (newlines → spaces, collapse multiple spaces).
        - [x] Dynamic bubble height calculation based on text length.
        - [x] Full-width bubble layout with margins.
    - [x] **UI/UX Refinements**:
        - [x] AR-style text bubbles with rounded corners and background.
        - [x] 3-second scan throttling for stability.
        - [x] Tap-to-select with visual feedback (green highlight).
        - [x] Pause stream on interaction for easier selection.
    - [x] **Integration**:
        - [x] Pass selected text to `SentenceEditScreen`.

### 2. Back Content Generation (AI Auto-Fill) - Smart Card Creation
- [x] **Method A: Manual Entry** (Already implemented)
    - [x] Input fields for Translation, Notes, and Examples in `SentenceEditScreen`.
- [ ] **Method B: AI Auto-Generation** (Tomorrow's Priority)
    - [ ] **UX Flow from Camera OCR**:
        - [ ] When form opens with `initialOriginalText`, auto-select all text in the field.
        - [ ] User can immediately paste/edit, or tap AI button.
    - [ ] **UI Changes (`SentenceEditScreen`)**:
        - [ ] Add `✨ AI` button in the bottom action bar (alongside Cancel/Save).
        - [ ] **Loading State**: Show overlay/spinner on the form while AI is generating.
        - [ ] **Error Handling**: Toast/Snackbar for API errors, timeout handling.
    - [ ] **AI Service Layer**:
        - [ ] Create `AiService` class (or use a Provider).
        - [ ] Integrate **Gemini API** (or OpenAI as fallback).
        - [ ] Secure API Key management (`.env` file, `flutter_dotenv` package).
    - [ ] **Prompt Engineering**:
        - [ ] System Prompt: "You are a helpful English tutor for Korean learners."
        - [ ] User Prompt Template:
            ```
            Given the following English sentence:
            "{originalText}"
            
            Generate:
            1. A natural Korean translation.
            2. Key grammar or vocabulary notes (1-2 bullet points).
            3. 2-3 example sentences using similar patterns.
            
            Return as JSON: { "translation": "...", "notes": "...", "examples": "..." }
            ```
        - [ ] Parse JSON response and populate form fields.
    - [ ] **Auto-Fill Logic**:
        - [ ] On AI button tap: Call `AiService.generateContent(originalText)`.
        - [ ] On success: Populate `translationController`, `notesController`, `examplesController`.
        - [ ] Allow user to review and edit before saving.
    - [ ] **Testing**:
        - [ ] Unit test for prompt formatting.
        - [ ] Mock API response for widget tests.

### 3. User Onboarding (Tutorial)
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

---

## 🛠 Future Ideas & Enhancements (Backlog)
- [ ] **Flashcard Timer Auto-Next**: Add a feature to automatically move to the next card after a set duration.
    - *Requirement*: Simple UI to toggle and adjust duration (e.g., 5s, 10s, 30s).
- [ ] **Default Sentences Seeding Rework**: Clean up and rework the initial data seeding logic.
    - *Requirement*: Instead of 134 items, provide only one "perfect" representative sentence for each difficulty (Beginner, Intermediate, Advanced) with rich notes/examples to guide the user.
- [ ] **Spaced Repetition System (SRS)**: Implement an algorithm like Anki for more efficient learning.
- [ ] **Voice Pronunciation**: Integrate Text-to-Speech (TTS) for the original sentences.
- [ ] **Cloud Sync**: Allow users to sync their data across devices using Firebase or Supabase.
- [ ] **Performance & Hardening**
    - [ ] **Database Stress Test**: Ensure performance remains stable with 1000+ sentences.
    - [ ] **Error Boundaries**: Implement a global error handling UI for unexpected crashes.
    - [ ] **Migration Strategy**: Document and test a basic DB migration plan for future schema changes.
- [ ] **Testing (Hardening)**
    - [ ] **Widget Tests**: Add tests for critical widgets (`SentenceCard`, `SentenceFilterBar`).
    - [ ] **Integration Tests**: Verify core flow (Add -> Find in List -> Flip in Study Mode -> Delete).
- [ ] **Gallery Image OCR**
    - [ ] Integrate `image_picker` for gallery access.
    - [ ] Perform OCR on selected image.
    - [ ] Workflow: Select Image -> Extract Text -> Paste to New Card -> Open Edit Screen.

