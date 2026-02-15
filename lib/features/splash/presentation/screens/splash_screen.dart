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
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Initialize TTS models (warmup)
      // This copies assets if needed, so first playback is fast.
      await ref.read(ttsServiceProvider).init();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // In a real app, we might show a retry button or error dialog.
      // For now, we log and proceed (TTS might just fail later, but core app works)
      // Or stay on Splash with error.
      // Let's retry or show simple error.
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to initialize TTS: $e')));
        // Navigate anyway so app is usable without TTS?
        // Or block? Tts is core feature?
        // User said "Self-healing". If that fails, it's serious.
        // But let's go to home to let user retry via settings or manual action if implemented later.
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match native splash
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Initializing AI models...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Powered by Supertone',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
