import 'package:camera/camera.dart';

class OcrInput {
  final String? filePath;
  final CameraImage? cameraImage;
  final int? rotationDegrees;

  OcrInput.fromFile(this.filePath) : cameraImage = null, rotationDegrees = null;
  OcrInput.fromCameraImage(this.cameraImage, this.rotationDegrees)
    : filePath = null;
}
