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
