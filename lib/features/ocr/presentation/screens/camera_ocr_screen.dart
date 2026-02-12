import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../features/sentences/domain/enums/app_language.dart';
import '../../../../features/sentences/domain/enums/script_type.dart';
import '../widgets/text_recognizer_painter.dart';
import '../utils/ocr_processor.dart';
import '../../domain/services/ocr_service.dart';
import '../../domain/models/ocr_input.dart';

class CameraOCRScreen extends StatefulWidget {
  final AppLanguage originalLang;
  final AppLanguage translationLang;

  const CameraOCRScreen({
    super.key,
    this.originalLang = AppLanguage.english,
    this.translationLang = AppLanguage.korean,
  });

  @override
  State<CameraOCRScreen> createState() => _CameraOCRScreenState();
}

class _CameraOCRScreenState extends State<CameraOCRScreen> {
  CameraController? _controller;
  final OcrService _ocrService = OcrService();

  bool _isCameraInitialized = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  List<DisplayBlock> _displayBlocks = [];
  final Set<String> _selectedTextBlocks = {};

  // Android-only: Live stream state
  bool _isStreamPaused = false;
  DateTime? _lastProcessedTime;
  static const Duration _throttleDuration = Duration(milliseconds: 3000);

  // iOS-only: Capture state
  bool _isProcessingCapture = false;

  // Bilingual Mode Toggle
  bool _isBilingualMode = true;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait up
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initializeCamera();
  }

  @override
  void dispose() {
    // Reset orientation preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _stopCamera();
    _ocrService.dispose();
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

    // Platform-specific resolution
    final resolution = Platform.isIOS
        ? ResolutionPreset
              .ultraHigh // iOS: Higher res for capture-based OCR
        : ResolutionPreset.high; // Android: Lower res for smooth live stream

    _controller = CameraController(
      cameras.first,
      resolution,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();
      final targetZoom = 1.2.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(targetZoom);
    } catch (e) {
      debugPrint('Failed to set zoom level: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });

      // Android only: Start live stream
      if (Platform.isAndroid) {
        await _startLiveFeed();
      }
    }
  }

  // ========================
  // Android: Live Stream OCR
  // ========================

  Future<void> _startLiveFeed() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startImageStream(_processCameraImage);
  }

  Future<void> _stopCamera() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (Platform.isAndroid) {
      try {
        await _controller!.stopImageStream();
      } catch (_) {}
    }

    await _controller!.dispose();
    _controller = null;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    if (_lastProcessedTime != null &&
        now.difference(_lastProcessedTime!) < _throttleDuration) {
      return;
    }
    _lastProcessedTime = now;

    if (_isBusy || _isStreamPaused) return;
    _isBusy = true;

    try {
      final rotationDegrees = _getRotationDegrees();
      final input = OcrInput.fromCameraImage(image, rotationDegrees);

      final currentScript = _isBilingualMode
          ? OcrScript.korean
          : OcrScript.latin;

      final recognizedBlocks = await _ocrService.processImage(
        input,
        script: currentScript,
      );

      if (mounted) {
        final canvasSize = MediaQuery.of(context).size;
        final imageSize = Size(image.width.toDouble(), image.height.toDouble());

        // Normalized focus region for Android
        const focusRegion = Rect.fromLTRB(0.0, 0.3, 1.0, 0.7);

        final filteredBlocks = OcrProcessor.processBlocks(
          recognizedBlocks,
          canvasSize,
          imageSize,
          rotationDegrees,
          focusRegion: focusRegion,
          shouldMerge: false, // Android: No merging
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

  // ========================
  // iOS: Manual Capture OCR
  // ========================

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessingCapture) return;

    setState(() {
      _isProcessingCapture = true;
      _displayBlocks.clear();
      _selectedTextBlocks.clear();
    });

    try {
      bool isCaptured = false;
      await _controller!.startImageStream((image) async {
        if (isCaptured) return;
        isCaptured = true;

        try {
          final input = OcrInput.fromCameraImage(image, 0); // iOS rotation 0

          final currentScript = _isBilingualMode
              ? OcrScript.korean
              : OcrScript.latin;

          final recognizedBlocks = await _ocrService.processImage(
            input,
            script: currentScript,
          );

          await _controller!.stopImageStream();

          if (mounted) {
            final canvasSize = MediaQuery.of(context).size;
            final imageSize = Size(
              image.width.toDouble(),
              image.height.toDouble(),
            );

            // Normalized focus region for iOS - center 40% of screen (portrait only)
            const focusRegion = Rect.fromLTRB(0.0, 0.3, 1.0, 0.7);

            final filteredBlocks = OcrProcessor.processBlocks(
              recognizedBlocks,
              canvasSize,
              imageSize,
              0, // No rotation needed
              focusRegion: focusRegion,
              shouldMerge: true, // iOS: Merge blocks into paragraphs
            );

            setState(() {
              _displayBlocks = filteredBlocks;
              _isProcessingCapture = false;
            });
            _paint();
          }
        } catch (e) {
          debugPrint('Error capturing/processing image: $e');
          await _controller?.stopImageStream();
          if (mounted) {
            setState(() {
              _isProcessingCapture = false;
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting capture stream: $e');
      if (mounted) {
        setState(() {
          _isProcessingCapture = false;
        });
      }
    }
  }

  // ========================
  // Common Methods
  // ========================

  int _getRotationDegrees() {
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    int rotation = 0;
    if (Platform.isIOS) {
      rotation = sensorOrientation;
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = rotationCompensation;
    }
    return rotation;
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Rect _getFocusRegion(Size screenSize) {
    final isLandscape = screenSize.width > screenSize.height;
    if (isLandscape) {
      final excludeWidth = screenSize.width * 0.3;
      return Rect.fromLTWH(
        excludeWidth,
        0,
        screenSize.width * 0.4,
        screenSize.height,
      );
    } else {
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
    // Pass a copy of the set to ensure changes are detected by shouldRepaint
    final painter = TextRecognizerPainter(
      _displayBlocks,
      Set.of(_selectedTextBlocks),
    );
    _customPaint = CustomPaint(painter: painter);
  }

  void _onTap(TapUpDetails details) {
    if (_controller == null) return;

    final localPosition = details.localPosition;
    final screenSize = MediaQuery.of(context).size;
    final focusRegion = _getFocusRegion(screenSize);

    // Check if tap is within focus region for auto-focus
    if (focusRegion.contains(localPosition)) {
      _triggerAutoFocus(localPosition, screenSize);
    }

    // Android: Pause stream on first tap
    if (Platform.isAndroid && !_isStreamPaused) {
      setState(() {
        _isStreamPaused = true;
      });
    }

    // Check if tapped on a text block
    String? tappedBlockText;
    for (final block in _displayBlocks) {
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
      });
      _updatePainterOnly();
    } else if (_displayBlocks.isNotEmpty) {
      // Tapped outside blocks - clear selection (Android: resume stream)
      setState(() {
        if (Platform.isAndroid) {
          _isStreamPaused = false;
        }
        _selectedTextBlocks.clear();
      });
    }
  }

  Future<void> _triggerAutoFocus(Offset point, Size screenSize) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Normalize point to 0.0-1.0 range
      final normalizedPoint = Offset(
        point.dx / screenSize.width,
        point.dy / screenSize.height,
      );

      await _controller!.setFocusPoint(normalizedPoint);
      await _controller!.setExposurePoint(normalizedPoint);
    } catch (e) {
      debugPrint('Auto-focus failed: $e');
    }
  }

  void _updatePainterOnly() {
    final painter = TextRecognizerPainter(
      _displayBlocks,
      Set.of(_selectedTextBlocks),
    );
    _customPaint = CustomPaint(painter: painter);
  }

  Future<void> _confirmSelection() async {
    final originalParts = <String>[];
    final translationParts = <String>[];

    for (final text in _selectedTextBlocks) {
      // Use the translation language's script type to classify
      final textScript = RegExp(r'[가-힣]').hasMatch(text)
          ? ScriptType.korean
          : ScriptType.latin;
      if (textScript == widget.translationLang.scriptType) {
        translationParts.add(text);
      } else {
        originalParts.add(text);
      }
    }

    final extra = {
      'original': originalParts.join('\n\n'),
      'translation': translationParts.join('\n\n'),
    };

    await context.push('/edit', extra: extra);
    if (mounted) {
      context.pop();
    }
  }

  void _clearAndReset() {
    setState(() {
      _displayBlocks.clear();
      _selectedTextBlocks.clear();
      _customPaint = null;
      if (Platform.isAndroid) {
        _isStreamPaused = false;
      }
    });
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
          CameraPreview(_controller!),

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

          // Scrollable Text Overlay
          if (_isCameraInitialized)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate required height for text blocks
                  double contentHeight = constraints.maxHeight;
                  if (_displayBlocks.isNotEmpty) {
                    final lastBlockBottom = _displayBlocks.last.rect.bottom;
                    contentHeight = math.max(
                      contentHeight,
                      lastBlockBottom + 150.0, // Extra padding at bottom
                    );
                  }

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: contentHeight,
                        child: Stack(
                          children: [
                            if (_customPaint != null) _customPaint!,
                            GestureDetector(
                              onTapUp: _onTap,
                              behavior: HitTestBehavior.translucent,
                              child: Container(color: Colors.transparent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // AppBar
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
              title: _buildTitle(),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isBilingualMode = !_isBilingualMode;
                      _displayBlocks.clear();
                    });
                  },
                  icon: Icon(
                    _isBilingualMode ? Icons.translate : Icons.language,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isBilingualMode
                        ? '${widget.originalLang.displayName}+${widget.translationLang.displayName}'
                        : widget.originalLang.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Selection Card (shown when blocks are selected)
          if (_selectedTextBlocks.isNotEmpty)
            Positioned(
              bottom: Platform.isIOS ? 120 : 40,
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
                        onPressed: _clearAndReset,
                        child: const Text('Clear Selection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // iOS: Capture Button
          if (Platform.isIOS)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Capture Button
                  GestureDetector(
                    onTap: _isProcessingCapture ? null : _captureAndProcess,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProcessingCapture
                            ? Colors.grey
                            : Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: _isProcessingCapture
                          ? const Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 32,
                            ),
                    ),
                  ),

                  // Clear/Refresh Button (Right side)
                  if (_displayBlocks.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      right: 60,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black45,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _clearAndReset,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Android: Hint text (when no blocks selected and stream not paused)
          if (Platform.isAndroid &&
              _selectedTextBlocks.isEmpty &&
              !_isStreamPaused)
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

          // iOS: Hint text (when no blocks and not processing)
          if (Platform.isIOS && _displayBlocks.isEmpty && !_isProcessingCapture)
            const Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Text(
                'Tap the button to scan text',
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

  Widget _buildTitle() {
    if (Platform.isIOS) {
      if (_isProcessingCapture) {
        return const Text(
          'Processing...',
          style: TextStyle(color: Colors.white70),
        );
      } else if (_displayBlocks.isNotEmpty) {
        return const Text(
          'Tap text to select',
          style: TextStyle(color: Colors.white),
        );
      } else {
        return const Text(
          'Position camera',
          style: TextStyle(color: Colors.white70),
        );
      }
    } else {
      // Android
      return _isStreamPaused
          ? const Text(
              'Tap text to select',
              style: TextStyle(color: Colors.white),
            )
          : const Text('Scanning...', style: TextStyle(color: Colors.white70));
    }
  }
}

class _FocusOverlayPainter extends CustomPainter {
  final Rect focusRegion;
  _FocusOverlayPainter(this.focusRegion);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRect(fullRect);
    final focusPath = Path()..addRect(focusRegion);
    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      focusPath,
    );
    canvas.drawPath(combinedPath, overlayPaint);
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
