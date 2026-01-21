import 'dart:io';
import '../models/ocr_block.dart';
import '../models/ocr_input.dart';
import '../../data/services/google_ml_kit_ocr_service.dart';
import '../../data/services/apple_vision_ocr_service.dart';

enum OcrScript { latin, korean }

abstract class OcrService {
  Future<List<OcrBlock>> processImage(
    OcrInput input, {
    OcrScript script = OcrScript.latin,
  });

  void dispose();

  factory OcrService() {
    if (Platform.isIOS) {
      return AppleVisionOcrService();
    } else {
      return GoogleMlKitOcrService();
    }
  }
}
