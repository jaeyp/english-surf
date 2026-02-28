import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:english_surf/core/router/app_router.dart';
import 'package:english_surf/core/theme/app_theme.dart';
import 'package:english_surf/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
import 'package:audio_service/audio_service.dart';
import 'package:english_surf/features/study/application/study_audio_handler.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');
      final prefs = await SharedPreferences.getInstance();

      Uri? artUri;
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/app_icon.png');
        if (!await file.exists()) {
          final byteData = await rootBundle.load('assets/icon/app_icon.png');
          await file.writeAsBytes(
            byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            ),
          );
        }
        artUri = Uri.parse('file://${file.path}');
      } catch (e) {
        // App icon load failure can be ignored safely
      }

      final audioHandler = await AudioService.init(
        builder: () => StudyAudioHandler(artUri: artUri),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.bridjh.lingopocket.channel.audio',
          androidNotificationChannelName: 'Study Mode Audio',
          androidNotificationOngoing: true,
        ),
      );

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            studyAudioHandlerProvider.overrideWithValue(audioHandler),
          ],
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
    },
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'LingoPocket',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      scrollBehavior: AppScrollBehavior(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
