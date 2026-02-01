# Rebrand Execution Protocol (Deep Dive)

**This is the detailed logic for the 'rebrand' skill. Execute every step below with 100% precision.**

## [STEP 1] Automated Metadata Update
- Ensure `rename` package is available (`flutter pub add rename --dev`).
- Run `flutter pub run rename setAppName --value "{NEW_APP_NAME}"`.
- Run `flutter pub run rename setBundleId --value "{NEW_BUNDLE_ID}"`.

## [STEP 2] Android Directory Surgery
- Physically move files in `android/app/src/main/kotlin/` or `java/` to the new path matching `{NEW_BUNDLE_ID}`.
- Update `package` declaration in `MainActivity`.
- Ensure `build.gradle` (app level) has matching `namespace` and `applicationId`.

## [STEP 3] iOS/macOS Consistency
- Verify `PRODUCT_NAME` and `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner/AppInfo.xcconfig`.
- Update `project.pbxproj` values safely without breaking UUIDs.

## [STEP 4] Global Search & Import Cleanup
- Change `name` in `pubspec.yaml` to `{NEW_PUBSPEC_NAME}`.
- Perform a global search and replace for all internal `import` statements.
- Update hardcoded strings in UI or logs if they refer to the old project name.

## [STEP 5] Final Sanitization
- Execute: `flutter clean` -> `flutter pub get`.
- For iOS: `cd ios && rm -rf Pods Podfile.lock && pod install`.

**Final Action:** Report all modified files and folder moves to the user.