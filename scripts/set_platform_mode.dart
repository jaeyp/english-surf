import 'dart:io';

const String kPubspecFile = 'pubspec.yaml';
const String kServiceFile =
    'lib/features/ocr/data/services/google_ml_kit_ocr_service.dart';

// Dependencies to toggle
const List<String> kGoogleMlKitDeps = [
  'google_mlkit_text_recognition',
  'google_mlkit_commons',
];

// Stub Content for 'ios_only' mode
const String kStubServiceContent = '''
import '../../domain/services/ocr_service.dart';
import '../../domain/models/ocr_block.dart';
import '../../domain/models/ocr_input.dart';

/// STUB implementation for iOS-only builds.
/// This file allows compilation without the google_mlkit packages.
class GoogleMlKitOcrService implements OcrService {
  @override
  Future<List<OcrBlock>> processImage(
    OcrInput input, {
    OcrScript script = OcrScript.latin,
  }) async {
    throw UnimplementedError('Google ML Kit is disabled in iOS-only mode.');
  }

  @override
  void dispose() {}
}
''';

// Real Content for 'hybrid' mode (will be restored from backup or hardcoded if backup missing)
// We rely on a backup file: .google_ml_kit_ocr_service.dart.bak
// If backup doesn't exist, we assume the current file is the real one and back it up before stubbing.

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart scripts/set_platform_mode.dart [ios_only | hybrid]');
    return;
  }

  final mode = args[0];

  if (mode == 'ios_only') {
    await setIosOnlyMode();
  } else if (mode == 'hybrid') {
    await setHybridMode();
  } else {
    print('Invalid mode: $mode. Use "ios_only" or "hybrid".');
  }
}

Future<void> setIosOnlyMode() async {
  print('Switching to iOS Only Mode...');

  // 1. Backup Real Service File if not already backed up
  final serviceFile = File(kServiceFile);
  final backupFile = File('$kServiceFile.bak');

  if (await serviceFile.exists()) {
    final content = await serviceFile.readAsString();
    if (!content.contains('STUB implementation')) {
      await backupFile.writeAsString(content);
      print('Backed up real service to: ${backupFile.path}');
    }
  }

  // 2. Overwrite Service File with Stub
  await serviceFile.writeAsString(kStubServiceContent);
  print('Overwrote service file with Stub implementation.');

  // 3. Comment out dependencies in pubspec.yaml
  final pubspec = File(kPubspecFile);
  if (!await pubspec.exists()) {
    print('Error: $kPubspecFile not found.');
    return;
  }

  final lines = await pubspec.readAsLines();
  final newLines = lines.map((line) {
    for (final dep in kGoogleMlKitDeps) {
      if (line.trim().startsWith(dep + ':')) {
        return '# $line'; // Comment out
      }
    }
    return line;
  }).toList();

  await pubspec.writeAsString(newLines.join('\n') + '\n');
  print('Commented out Google ML Kit dependencies in $kPubspecFile.');

  // 4. Run pub get
  print('Running flutter pub get...');
  final result = await Process.run('flutter', ['pub', 'get']);
  if (result.exitCode == 0) {
    print('Success.');
  } else {
    print('Error running pub get:\\n${result.stderr}');
  }
}

Future<void> setHybridMode() async {
  print('Switching to Hybrid Mode (Android + iOS)...');

  // 1. Restore Real Service File from Backup
  final serviceFile = File(kServiceFile);
  final backupFile = File('$kServiceFile.bak');

  if (await backupFile.exists()) {
    final content = await backupFile.readAsString();
    await serviceFile.writeAsString(content);
    print('Restored real service from backup.');
  } else {
    print(
      'Warning: Backup file not found. Could not restore real service implementation.',
    );
    print('You may need to manually revert changes to $kServiceFile.');
  }

  // 2. Uncomment dependencies in pubspec.yaml
  final pubspec = File(kPubspecFile);
  if (!await pubspec.exists()) {
    print('Error: $kPubspecFile not found.');
    return;
  }

  final lines = await pubspec.readAsLines();
  final newLines = lines.map((line) {
    for (final dep in kGoogleMlKitDeps) {
      if (line.trim().startsWith('#') && line.contains(dep + ':')) {
        return line.replaceFirst('# ', ''); // Uncomment
      }
    }
    return line;
  }).toList();

  await pubspec.writeAsString(newLines.join('\n') + '\n');
  print('Restored Google ML Kit dependencies in $kPubspecFile.');

  // 3. Run pub get
  print('Running flutter pub get...');
  final result = await Process.run('flutter', ['pub', 'get']);
  if (result.exitCode == 0) {
    print('Success.');
  } else {
    print('Error running pub get:\\n${result.stderr}');
  }
}
