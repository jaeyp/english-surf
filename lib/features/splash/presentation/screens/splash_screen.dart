import 'dart:async';

import 'package:english_surf/features/tts/service/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // Define a list of gradients to cycle through for the "wave" effect
  final List<List<Color>> _gradientColors = [
    [Colors.purple, Colors.blue],
    [Colors.blue, Colors.teal],
    [Colors.teal, Colors.green],
    [Colors.green, Colors.yellow],
    [Colors.yellow, Colors.orange],
    [Colors.orange, Colors.red],
    [Colors.red, Colors.purple],
  ];

  int _currentGradientIndex = 0;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _initApp();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    // Change gradient every 1 second
    _animationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentGradientIndex =
              (_currentGradientIndex + 1) % _gradientColors.length;
        });
      }
    });
  }

  Future<void> _initApp() async {
    try {
      // Run initialization and minimum delay in parallel
      await Future.wait([
        ref.read(ttsServiceProvider).init(),
        Future.delayed(const Duration(seconds: 2)),
      ]);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to initialize TTS: $e')));
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        onEnd: () {
          // Verify animation loop if needed, but Timer handles the trigger
        },
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors[_currentGradientIndex],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Lingo Pocket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Initializing...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Powered by Supertone',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
