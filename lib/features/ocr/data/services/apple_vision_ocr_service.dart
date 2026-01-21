import 'dart:io';
import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../domain/services/ocr_service.dart';
import '../../domain/models/ocr_block.dart';
import '../../domain/models/ocr_input.dart';

class AppleVisionOcrService implements OcrService {
  final _controller = AppleVisionRecognizeTextController();

  @override
  Future<List<OcrBlock>> processImage(
    OcrInput input, {
    OcrScript script = OcrScript.latin,
  }) async {
    Uint8List? imageBytes;
    Size? imageSize;
    ImageOrientation orientation = ImageOrientation.up;

    if (input.filePath != null) {
      // Load image from file path (for manual capture mode)
      final file = File(input.filePath!);
      final bytes = await file.readAsBytes();

      // Decode to get dimensions
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return [];

      imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());

      // Re-encode as JPEG for Vision API
      imageBytes = img.encodeJpg(decoded, quality: 90);
      orientation = ImageOrientation.up;
    } else if (input.cameraImage != null) {
      final cameraImage = input.cameraImage!;
      imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      // Convert CameraImage (BGRA8888) to JPEG bytes
      if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        final plane = cameraImage.planes[0];

        final imgImage = img.Image.fromBytes(
          width: cameraImage.width,
          height: cameraImage.height,
          bytes: plane.bytes.buffer,
          order: img.ChannelOrder.bgra,
          numChannels: 4,
        );

        imageBytes = img.encodeJpg(imgImage, quality: 80);
      } else {
        return [];
      }

      // Map rotation
      if (imageSize.height > imageSize.width) {
        orientation = ImageOrientation.up;
      } else {
        orientation = _mapOrientation(input.rotationDegrees ?? 0);
      }
    }

    if (imageBytes == null || imageSize == null) return [];

    final data = RecognizeTextData(
      image: imageBytes,
      imageSize: imageSize,
      orientation: orientation,
      recognitionLevel: RecognitionLevel.accurate,
      automaticallyDetectsLanguage: true,
    );

    final result = await _controller.processImage(data);

    if (result == null) return [];

    return result.map((e) {
      Rect rect = e.boundingBox;

      // Plugin bug: origin (L,T) is in pixel coordinates, but size (R-L, B-T) is still normalized
      final normalizedWidth = rect.right - rect.left;
      final normalizedHeight = rect.bottom - rect.top;

      final actualWidth = normalizedWidth * imageSize!.width;
      final actualHeight = normalizedHeight * imageSize.height;

      // Vision uses bottom-left origin, so flip Y
      final flutterTop = imageSize.height - rect.top - actualHeight;

      rect = Rect.fromLTRB(
        rect.left,
        flutterTop,
        rect.left + actualWidth,
        flutterTop + actualHeight,
      );

      return OcrBlock(
        text: e.listText.isNotEmpty ? e.listText.first : '',
        rect: rect,
      );
    }).toList();
  }

  ImageOrientation _mapOrientation(int degrees) {
    switch (degrees) {
      case 0:
        return ImageOrientation.up;
      case 90:
        return ImageOrientation.right;
      case 180:
        return ImageOrientation.down;
      case 270:
        return ImageOrientation.left;
      default:
        return ImageOrientation.up;
    }
  }

  @override
  void dispose() {
    // No specific disposal needed
  }
}
