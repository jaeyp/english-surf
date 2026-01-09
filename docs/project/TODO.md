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
- **Phase 4.1: Polishing & Hardening** (✅ Completed)
- **Phase 4.2: Folder System** (✅ Completed)
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

## Phase 4.2: Folder System (Enhanced Organization) [Completed]
- [x] **Data Layer (Core)**
    - [x] Create `Folder` entity: `id`, `name`, `createdAt`.
    - [x] **Update `Sentence` entity**: Add `folderId` (nullable, UUID).
    - [x] **Database Migration**: 
        - [x] Add `folders` table.
        - [x] Add `folder_id` column to `sentences` table (Foreign Key).
    - [x] Implement `FolderRepository` for CRUD.
    - [x] **Seeding Logic**: Auto-create "Default" folder and move all existing sentences into it during first migration.
- [x] **State Management**
    - [x] `FolderListProvider`: Manage all folders.
    - [x] `CurrentFolderProvider`: Track which folder the user is currently viewing.
    - [x] Update `SentenceListProvider`: Add filtering logic by `folderId`.
- [x] **UI Implementation**
    - [x] **Home Screen (Folder Grid/List)**: Show list of folders with sentence counts.
    - [x] **Folder Operations**: Create/Rename/Delete Folder with name validation.
    - [x] **Sentence List (Folder View)**: Breadcrumbs (Home > Folder Name) and empty state UI.
- [x] **Multi-selection & Bulk Actions**
    - [x] **Selection Mode**: Long-press activation + Contextual AppBar (Selection Count, Select All).
    - [x] **Floating Action Bottom Bar**: Quick actions for [Move] / [Delete].
    - [x] **Visual Feedback**: Checkbox slide-in + card highlight.
    - [x] **Batch Operations**: 
        - [x] Bulk Move: "Folder Picker" via Bottom Sheet (Select from existing folders, including current).
        - [x] Bulk Delete: Multi-item confirmation dialog.
- [ ] **Testing**
    - [ ] Unit tests for `FolderRepository`.
    - [ ] Widget tests for folder CRUD UI.

## Phase 4.3: Card Swipe Actions Improvement
- [x] **Swipe Behavior Changes**
    - [x] Disable swipe-to-right (Left-to-Right swipe: card should not move).
    - [x] Reveal 3 actions on the right side when swipe-to-left (Right-to-Left swipe).
- [x] **New Favorite Feature**
    - [x] Add `isFavorite` field to `Sentence` entity (boolean, default: false).
    - [x] Implement database migration for the new field.
    - [x] Update repository to handle favorite toggle.
- [x] **Right Swipe Menu UI**
    - [x] Display 3 action buttons in order: Favorite → Edit → Delete.
    - [x] **Favorite Button**: Star icon (outlined when off, filled red when on). Tap to toggle.
    - [x] **Edit Button**: Pencil icon. Tap to navigate to `SentenceEditScreen`.
    - [x] **Delete Button**: Trash icon. Tap to show delete confirmation popup.
- [x] **Filter UI Improvements**
  - [x] Remove "Sort: " and "Difficulty: " text labels from `SentenceFilterBar` chips.
  - [x] Add "Favorites" option to the filter menu (placed after "All").
  - [x] **Study Mode Stability & Hardening**
  - [x] **Stable List View**: Implemented "Frozen IDs" to prevent cards from vanishing during study.
  - [x] **Timer & Gestures**: Verified timer pause on flip and fixed tap propagation issues. Added manual Pause/Resume on tap.
  - [x] **Drag & Drop Reordering**: Integrated `SliverReorderableList` with selection mode (active when sorted by 'order').
  - [x] **TDD**: 41 unit/widget/stability tests passing.

## Phase 5: Advanced Input & AI Integration (🚧 In Progress)

### Phase 5.1: New Sentence Addition Methods (Camera OCR)
- [x] **Method A: Manual Entry** (Standard form in `SentenceEditScreen`)
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
        - [x] **Zoom Optimization**: Balanced **1.2x zoom** for better readability.
        - [x] **Scan Throttling**: 1.5s initial delay before scanning begins for stability.
        - [x] **Focus Region Logic**: Optimized middle 40% region (portrait & landscape).
        - [x] **Tight Block Stacking**: Blocks are now stacked with consistent margin and padding for a compact UI.
        - [x] **Z-Index Correction**: Fixed overlay covering interactive text blocks.
    - [x] **Integration**:
        - [x] Pass selected text to `SentenceEditScreen`.

### Phase 5.2: Back Content Generation (AI Auto-Fill) - Smart Card Creation (✅ Completed)
- [x] **AI Auto-Generation Implementation (.env basis)**:
    - [x] **Plan AI infrastructure and prompt engineering**.
    - [x] **Add `googleai_dart` dependency (v3.0.0) and API key in `.env`**.
    - [x] **Model**: Using **`gemini-2.5-flash-lite`** with **v1beta** API endpoint.
    - [x] **Multi-Provider AI Architecture**:
        - [x] Refactored into `AiDataSource` (Interface) and `AiRepository` (Facade).
        - [x] Implemented `GroqAiDataSource` using `http` package.
        - [x] Integrated `GROQ_API_KEY` supporting models like `Llama 3.3`.
    - [x] **AI Service Layer**:
        - [x] Secure API Key management via `.env`.
    - [x] **Prompt Engineering 2.0 (Multi-Note & Style Focus)**:
        - [x] System Prompt: "You are a modern English tutor."
        - [x] **Style Interaction**: AI extracts notes based on bold/highlight text.
        - [x] **Flexible Notes**: Support for 1-3 natural notes.
        - [x] **Difficulty Suggestion**: AI recommends sentence difficulty.
        - [x] Parse complex JSON response and populate form fields.
    - [x] **UI Changes (`SentenceEditScreen`)**:
        - [x] Add `✨ AI Auto-fill` button in the action bar.
        - [x] **Loading State**: Show overlay/spinner while generating.
        - [x] **Error Handling**: Toast/Snackbar for API errors.
        - [x] **Auto-Fill**: Populate controllers (`translation`, `difficulty`, `notes`, `examples`) on success.
    - [x] **Testing**:
        - [x] Unit test for prompt formatting and JSON parsing.
        - [x] Mock AI response for widget tests. (Note: widget tests rely on AiRepository mocking).

### Phase 5.3: Multi-Language Foundation (Schema, Model & AI Sync)
- [ ] **Database Migration (v3 -> v4)**:
    - [ ] Update `Sentences` table: Change `translation` (String) to `translations` (JSON Map).
    - [ ] **Migration Logic**: Move existing string to `{"korean": value}` using lowercase keys.
- [ ] **Domain Model Refactoring**:
    - [ ] Update `Sentence` entity to use `Map<String, String> translations`.
    - [ ] Update all repository and mapper implementations.
- [ ] **AI Multi-Language Sync**:
    - [ ] **Dynamic Multi-Fill**: AI auto-fills translation for *all* selected languages (Casual tone).
    - [ ] **Prompt Tuning**: Dynamically inject selected languages into the AI system prompt.
    - [ ] **Localization Prep**: Ensure the AI instructions handle different favorite translation languages naturally.
- [ ] **Edit Screen UI Update**:
    - [ ] Display translations for all selected languages in `SentenceEditScreen`.
    - [ ] **Primary Focus**: Place the Primary Translation at the top.
    - [ ] **Visual Distinction**: Apply a blue border to the Primary Translation field.

### Phase 5.4: Setup Onboarding & Core Settings (✅ Completed)
- [x] **Settings Screen Entry**:
    - [x] Add Settings button to Folder View (top title bar, right end).
- [ ] **Language Preferences**:
    - [ ] **Multi-Language Selection**: Select up to 4 favorite translation languages.
    - [ ] **Default Selection**: Designate 1 Primary language for the card back view.
    - [ ] **Language List**: Support 24 languages in alphabetical order:
        - Arabic, Chinese, Czech, Danish, Dutch, Finnish, French, German, Greek, Hindi, Hungarian, Italian, Japanese, Korean, Latin, Polish, Portuguese, Romanian, Russian, Spanish, Swedish, Thai, Turkish, Vietnamese.
- [ ] **Setup Onboarding**:
    - [ ] Implement a setup-onboarding screen for first-run language selection.
    - [ ] Skip onboarding if preferences are already set.
- [x] **AI Model Selection (Multi-Provider)**:
    - [x] Add option to select between AI Providers (Google, Groq).
    - [x] Dynamically switch models based on selected provider.
    - [x] **Persistence**: Save selection in `SharedPreferences`.

### Phase 5.5: AI+ Advanced Editing
- [ ] **AI+ Example Generator**:
    - [ ] Add `AI+` button next to "Add Example" in `SentenceEditScreen`.
    - [ ] **Logic**: Generate relevant example sentences based on the current `Notes` content.
    - [ ] **UX**: Show inline loading and append generated examples to the list.

### Phase 5.6: Speech & Audio (TTS)
- [ ] **Text-to-Speech (TTS) Integration**:
    - [ ] Integrate `flutter_tts` package.
- [ ] **UI Integration**:
    - [ ] Add Speaker icon at the end of text on Card Front (Original).
    - [ ] Add Speaker icon at the end of text on Card Back (Translation).
- [ ] **Logic**: Detect language (Original: English, Translation: Selected Preference) and play audio on tap.

### Phase 5.7: User Onboarding (Tutorial)
- [ ] **Coach Mark Overlay**
    - [ ] Integrate `tutorial_coach_mark` package.
    - [ ] **Design**: Use "Hand-drawn" style assets (arrows, circles) & Handwriting Font.
    - [ ] **Logic**: Implement First-run check (Show only once per screen).
    - [ ] **Scenarios**:
        - `SentenceListScreen`: Explain Swipe actions, Filter chips, Language toggle.
        - `StudyModeScreen`: Explain Tap to Flip, Swipe to Navigate.
        - `SentenceEditScreen`: Explain AI Auto-fill, OCR options, Text Styling, AI+ examples.

### Phase 5.8: BYOK (Bring Your Own Key) Settings UI
- [ ] Update `SettingsRepository` to store user-provided Gemini Key.
- [ ] Implement a Settings Dialog for users to manage their own key.
- [ ] Switch `AiRepository` to use the user-provided key if available.

### Phase 5.9: Data Portability (Import/Export)
- [ ] **JSON Portability (Full Backup)**:
    - [ ] Design a JSON schema that wraps sentences inside folder objects.
    - [ ] Export/Import the entire database as a single `.json` file.
- [ ] **CSV Portability (Folder-specific)**:
    - [ ] **Folder Name as Filename**: Use folder name as filename during export.
    - [ ] Support flat CSV structure for tabular editing.
- [ ] **UX & Integration**:
    - [ ] Implement a "Data Management" menu in Settings.
    - [ ] Use `file_picker` for importing and `share_plus` for exporting.

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
    - [x] Create App Icons & Launch Screen(Splash Screen).
    - [ ] Generate Screenshots & App Description.
- [ ] **Play Store (Android) Prep**
    - [ ] Configure `AndroidManifest.xml`.
    - [ ] Sign the App (Keystore generation).
    - [ ] Generate Screenshots & Feature Graphic.
- [ ] **Compliance**
    - [ ] Add Privacy Policy link.
    - [ ] Add Terms of Service.

---

## 🛠 Maintenance & Stability Log

### 🔋 UI Polish & Flagging System (2026-01-09)
- [x] **Home Screen Redesign**: Transitioned from Grid View to a clean, edge-to-edge List View layout.
- [x] **Persistent Filters**: Implemented folder-specific color flags (Bookmarks) that persist in the database.
- [x] **Dynamic Filtering**: Added a smart Filter Bar that automatically shows only active flags.
- [x] **UI Refinement**: Polished the folder list item layout (Stack-based, 54px text indentation, absolute bookmark positioning) and removed generic folder icons.

### 🔋 Multi-Provider AI & Advanced Settings (2026-01-07)
- [x] **Groq Integration**: Added support for Groq AI via REST API with `http` package.
- [x] **Multi-Provider Architecture**: Refactored `AiRepository` as a facade pattern for easy provider switching.
- [x] **Settings UI**: Created dedicated Settings screen for AI provider and model selection.
- [x] **Persistence**: All AI settings (provider, model) are now persistent via `SharedPreferences`.
- [x] **Bug Fix**: Resolved `AsyncValue` related build errors in `SentenceEditScreen` after provider refactoring.
- [x] **UI Polish**: Relocated Settings icon from card list to folder view (main screen).

### 🔋 UX & Configuration Adjustments (2025-01-02)
- [x] **Test Mode Repeat**: Implemented infinite repeat logic for Test Mode.
    - Automatically jumps back to the first card when the cycle ends.
    - Re-shuffles the list for each new cycle if the sort mode is "Random".
- [x] **Test Mode Timer**: Increased auto-advance timer from 5 seconds to **10 seconds** in `StudyModeScreen`. (2024-12-31)

### 🔋 UX & AI Intelligence Polish (2024-12-29)
- [x] **AI Auto-Fill 2.0**:
    - [x] **Style-based Focus**: AI now extracts notes based on user's bold/highlight styling.
    - [x] **Flexible Notes**: Support for 1-3 natural notes instead of fixed quantity.
    - [x] **Smart Difficulty**: AI suggests and applies sentence difficulty (Beginner/Inter/Adv).
    - [x] **Refined Prompt**: Prioritized modern daily talk over outdated idioms.
- [x] **Editor UX Improvements**:
    - [x] **Multi-line Examples**: Text fields now grow dynamically up to 5 lines.
    - [x] **Wider Layout**: Reduced button spacing to maximize text input width.
- [x] **Study & Navigation**:
    - [x] **Timer Control**: Added Pause/Resume functionality to Test Mode timer.
    - [x] **Deletion Logic**: Fixed navigation to return to list after card deletion.
- [x] **OCR Camera Polish**:
    - [x] **Scanning Delay**: Added 1.5s delay before start to allow positioning.
    - [x] **Wide Angle**: Reset default zoom to 1.0x for better overall vision.

### 🔋 Stability & Performance Fixes (2024-12-28)
- [x] **Card Save Bug Fix**: Fixed critical bug where saving a card deleted it (missing `folderId` and `isFavorite` preservation).
- [x] **OCR Selection Refresh Fix**: Fixed bug where card list wouldn't refresh after creating a card from OCR (navigation stack fix).
- [x] **Camera OCR Polish**: Adjusted zoom to 1.5x, added focus region overlay, and implemented tight block stacking.
- [x] **AI Prompt Tuning**: Refined prompts for better key expression extraction and diverse example generation.

### 🔋 Stability & Performance Fixes (2024-12-27)
- [x] **Filtering Lag Fix**: Simplified filter update logic in `SentenceListScreen` to reset visible IDs immediately.
- [x] **Post-Study Sync**: Ensured the list view refreshes after returning from the study screen.
- [x] **Direct Favorite Toggle Sync**: Fixed immediate UI update when toggling favorites directly in the list while filtered.
- [x] **Housecleaning**: Removed all temporary `test_results*.txt` and `flutter_run_log.txt` files to keep the project directory clean.

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
