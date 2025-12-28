// Standalone script to list available Gemini models using direct HTTP call.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  // Read API key from .env file
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('ERROR: .env file not found');
    return;
  }

  final envContent = await envFile.readAsString();
  String? apiKey;
  for (final line in envContent.split('\n')) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.substring('GEMINI_API_KEY='.length).trim();
      break;
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('ERROR: GEMINI_API_KEY not found in .env');
    return;
  }

  print('API Key loaded (first 10 chars): ${apiKey.substring(0, 10)}...');

  // Try v1 API
  print('\n--- Listing models with v1 API ---');
  await listModels(apiKey, 'v1');

  // Try v1beta API
  print('\n--- Listing models with v1beta API ---');
  await listModels(apiKey, 'v1beta');
}

Future<void> listModels(String apiKey, String version) async {
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/$version/models?key=$apiKey',
  );

  try {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final models = data['models'] as List<dynamic>?;
      if (models != null) {
        print('Available models ($version):');
        for (final model in models) {
          final name = model['name'];
          final displayName = model['displayName'];
          final supportedMethods = model['supportedGenerationMethods'];
          print('  - $name');
          print('      displayName: $displayName');
          print('      supportedMethods: $supportedMethods');
        }
      } else {
        print('No models found in response.');
      }
    } else {
      print('Error ($version): HTTP ${response.statusCode}');
      print('Response: $body');
    }
    client.close();
  } catch (e) {
    print('Error listing $version models: $e');
  }
}
