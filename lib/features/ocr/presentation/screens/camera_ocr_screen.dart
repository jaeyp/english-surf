import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/text_recognizer_painter.dart';
import '../utils/ocr_processor.dart';

class CameraOCRScreen extends StatefulWidget {
  const CameraOCRScreen({super.key});

  @override
  State<CameraOCRScreen> createState() => _CameraOCRScreenState();
}

class _CameraOCRScreenState extends State<CameraOCRScreen> {
  CameraController? _controller;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isCameraInitialized = false;
  final bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  // RecognizedText? _recognizedText; // Replaced by _displayBlocks
  List<DisplayBlock> _displayBlocks = [];
  final Set<String> _selectedTextBlocks = {}; // Stores text of selected blocks
  // In a real app, storing indices/IDs or rects might be safer if text is duplicate,
  // but ML Kit doesn't expose stable IDs across frames easily. Using text content for now.
  // Ideally we would freeze the frame to select, but let's try live selection first or pause on touch.

  // Actually, live selection on a moving stream is UX chaos.
  // Better UX: Freezing the frame (pause stream) implies taking a picture?
  // No, proper "Live Text" usually highlights what it sees.
  // Tap to select: We should store the *exact* block instance from the current frame?
  // No, frames update too fast.
  // Strategy: We will just toggle "Auto-Scan Mode" vs "Selection Mode"?
  // Let's stick to the requirements: "Tap to select".
  // If I tap a block, it adds to selection.
  // We need to persist selection across frames? That's hard if the text moves.
  // SIMPLIFICATION: When user taps, we PAUSE the stream to allow stable selection.
  bool _isStreamPaused = false;
  DateTime? _lastProcessedTime;
  static const Duration _throttleDuration = Duration(milliseconds: 3000);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied.')),
        );
        context.pop();
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No cameras found.')));
        context.pop();
      }
      return;
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();
      // Set to 1.0x zoom, but clamp within device limits
      final targetZoom = 1.2.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(targetZoom);
    } catch (e) {
      debugPrint('Failed to set zoom level: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
      await _startLiveFeed();
    }
  }

  Future<void> _startLiveFeed() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    // Give the user 1.5 seconds to position the camera before starting scanning
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startImageStream(_processCameraImage);
  }

  Future<void> _stopLiveFeed() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.stopImageStream();
    await _controller!.dispose();
    _controller = null;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    // 1. Throttle to prevent flickering & high CPU usage (1000ms)
    final now = DateTime.now();
    if (_lastProcessedTime != null &&
        now.difference(_lastProcessedTime!) < _throttleDuration) {
      return;
    }
    _lastProcessedTime = now;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    if (!_canProcess || _isBusy || _isStreamPaused) return;
    _isBusy = true;

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      if (mounted) {
        // Use whole screen size for canvas mapping
        final canvasSize = MediaQuery.of(context).size;
        final imageSize = inputImage.metadata!.size;

        // Normalized focus region: middle 40% (from 0.30 to 0.70)
        // This is in normalized image coordinates (0.0 to 1.0)
        const focusRegion = Rect.fromLTRB(0.3, 0.3, 0.7, 0.7);

        final filteredBlocks = OcrProcessor.processBlocks(
          recognizedText,
          canvasSize,
          imageSize,
          inputImage.metadata!.rotation,
          focusRegion: focusRegion,
        );

        setState(() {
          _displayBlocks = filteredBlocks;
        });
        _paint();
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }

    _isBusy = false;
  }

  /// Returns the focus region rect based on screen orientation.
  /// Portrait: middle 1/3 vertically (excludes top and bottom 1/3)
  /// Landscape: middle 1/3 horizontally (excludes left and right 1/3)
  Rect _getFocusRegion(Size screenSize) {
    final isLandscape = screenSize.width > screenSize.height;
    if (isLandscape) {
      // Landscape: exclude left and right 30% (middle 40%)
      final excludeWidth = screenSize.width * 0.3;
      return Rect.fromLTWH(
        excludeWidth,
        0,
        screenSize.width * 0.4,
        screenSize.height,
      );
    } else {
      // Portrait: exclude top and bottom 30% (middle 40%)
      final excludeHeight = screenSize.height * 0.3;
      return Rect.fromLTWH(
        0,
        excludeHeight,
        screenSize.width,
        screenSize.height * 0.4,
      );
    }
  }

  void _paint() {
    final painter = TextRecognizerPainter(_displayBlocks, _selectedTextBlocks);

    _customPaint = CustomPaint(painter: painter);
  }

  // =========================================================================
  // InputImage Conversion Logic (Standard Boilerplate)
  // =========================================================================
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    // Simplification for rotation
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    // Format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      // Skipping unsupported formats
      return null;
    }

    if (image.planes.length != 1 && format == InputImageFormat.bgra8888) {
      return null;
    }
    // NV21 has 3 planes, BGRA8888 has 1

    // Bytes
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // =========================================================================
  // Interaction Logic
  // =========================================================================

  void _onTap(TapUpDetails details) {
    if (_controller == null) return;

    // Pause stream on first interaction to make selection easier
    if (!_isStreamPaused) {
      setState(() {
        _isStreamPaused = true;
      });
      // We stop the stream controller callback execution effectively by the bool flag
      // but we don't necessarily need to stop the camera stream itself if we just ignore frames.
      // But purely pausing visual updates is enough.
    }

    final localPosition =
        details.localPosition; // Position in widget coordinates

    // Simplified logic: DisplayBlocks are already in screen coordinates!
    String? tappedBlockText;

    for (final block in _displayBlocks) {
      // Inflate slightly for touch area
      if (block.rect.inflate(8.0).contains(localPosition)) {
        tappedBlockText = block.text;
        break;
      }
    }

    if (tappedBlockText != null) {
      setState(() {
        if (_selectedTextBlocks.contains(tappedBlockText)) {
          _selectedTextBlocks.remove(tappedBlockText);
        } else {
          _selectedTextBlocks.add(tappedBlockText!);
        }
        // Force repaint with new selection (using existing recognized text)
        // We construct a fake input image wrapper just to trigger paint?
        // Or extract paint logic.
        // Actually `_paint` takes `InputImage`, which we don't have here.
        // We should store the last used Metadata/Size/Rotation.
      });

      // Manually trigger repaint if we are paused
      // We can't call `_paint` easily.
      // We need to update `_customPaint` directly.
      _updatePainterOnly();
    } else {
      // Tap outside -> Resume stream?
      setState(() {
        _isStreamPaused = false;
        _selectedTextBlocks.clear();
      });
    }
  }

  void _updatePainterOnly() {
    final painter = TextRecognizerPainter(_displayBlocks, _selectedTextBlocks);
    _customPaint = CustomPaint(painter: painter);
  }

  // Duplication of Painter logic for hit testing

  Future<void> _confirmSelection() async {
    final text = _selectedTextBlocks.join('\n\n');
    await context.push('/edit', extra: text);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview (base layer)
          CameraPreview(_controller!),

          // 2. Focus Region Overlay (gray out excluded areas)
          LayoutBuilder(
            builder: (context, constraints) {
              final screenSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final focusRegion = _getFocusRegion(screenSize);
              return CustomPaint(
                size: screenSize,
                painter: _FocusOverlayPainter(focusRegion),
              );
            },
          ),

          // 3. Text Recognition Overlay (on top of focus overlay)
          if (_customPaint != null) _customPaint!,

          // 2. Gesture Detector for Taps
          GestureDetector(
            onTapUp: _onTap,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent), // Expand to fill
          ),

          // 3. AppBar (Close)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              title: _isStreamPaused
                  ? const Text(
                      'Tap text to select',
                      style: TextStyle(color: Colors.white),
                    )
                  : const Text(
                      'Scanning...',
                      style: TextStyle(color: Colors.white70),
                    ),
            ),
          ),

          // 4. Action Bar (Bottom)
          if (_selectedTextBlocks.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedTextBlocks.length} blocks selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add to Sentence'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedTextBlocks.clear();
                            _isStreamPaused = false;
                          });
                        },
                        child: const Text('Clear Selection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Hint text if nothing selected
          if (_selectedTextBlocks.isEmpty)
            const Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Text(
                'Tap detected text to select',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter that draws a semi-transparent gray overlay on excluded areas.
/// The focus region (center 1/3) remains clear while outer areas are dimmed.
class _FocusOverlayPainter extends CustomPainter {
  final Rect focusRegion;

  _FocusOverlayPainter(this.focusRegion);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create a path that covers the entire screen
    final path = Path()..addRect(fullRect);

    // Subtract the focus region (creates a "hole" in the overlay)
    final focusPath = Path()..addRect(focusRegion);
    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      focusPath,
    );

    canvas.drawPath(combinedPath, overlayPaint);

    // Draw a subtle border around the focus region
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(focusRegion, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _FocusOverlayPainter oldDelegate) {
    return oldDelegate.focusRegion != focusRegion;
  }
}
