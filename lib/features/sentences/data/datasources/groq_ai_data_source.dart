import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'base_ai_data_source.dart';

class GroqAiDataSource extends BaseAiDataSource {
  final String _apiKey;
  final String _modelName;
  final http.Client _client;

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  GroqAiDataSource({
    required String apiKey,
    required String modelName,
    http.Client? client,
  }) : _apiKey = apiKey,
       _modelName = modelName,
       _client = client ?? http.Client();

  @override
  Future<String> performRequest({
    required String prompt,
    required String systemInstruction,
    bool jsonMode = false,
    double? temperature,
  }) async {
    final body = {
      'model': _modelName,
      'messages': [
        {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': prompt},
      ],
      if (jsonMode) 'response_format': {'type': 'json_object'},
      if (temperature != null) 'temperature': temperature,
    };

    developer.log(
      'Groq AI Request - Model: $_modelName',
      name: 'GroqAiDataSource',
    );

    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Groq API Error: ${response.statusCode} ${response.body}',
        );
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'] as String;
      return content;
    } catch (e) {
      developer.log(
        'Groq API Exception: $e',
        name: 'GroqAiDataSource',
        error: e,
      );
      rethrow;
    }
  }
}
