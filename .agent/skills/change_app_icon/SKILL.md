---
name: change_app_icon
description: Updates the app icon for all platforms when `assets/icon/app_icon.png` is modified.
---

# Change App Icon Skill

This skill automates the process of updating the application icon across all platforms (iOS, Android, etc.) using `flutter_launcher_icons`.

## Prerequisites
1.  Ensure the new icon image is placed at `assets/icon/app_icon.png`.
2.  Ensure `pubspec.yaml` contains the `flutter_launcher_icons` configuration (it should already be there).

## Steps

1.  **Verify Icon File**: Confirm `assets/icon/app_icon.png` exists and is the correct new image.
2.  **Run Generation Command**: Execute the following command in the terminal to generate platform-specific icons:
    ```bash
    flutter pub run flutter_launcher_icons
    ```
3.  **Verify Output**: Check if the icons were generated successfully (look for "Successfully generated launcher icons" in the output).
4.  **Clean Build (Optional)**: If the icon doesn't update immediately on the device/simulator, run:
    ```bash
    flutter clean
    flutter pub get
    ```
5.  **Restart App**: Uninstall the app from the device and run it again to force the launcher to refresh the icon.
