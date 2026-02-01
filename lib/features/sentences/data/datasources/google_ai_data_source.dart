import 'dart:developer' as developer;
import 'package:googleai_dart/googleai_dart.dart';
import 'base_ai_data_source.dart';

class GoogleAiDataSource extends BaseAiDataSource {
  final GoogleAIClient _client;
  final String _modelName;

  GoogleAiDataSource(this._client, {required String modelName})
    : _modelName = modelName;

  @override
  Future<String> performRequest({
    required String prompt,
    required String systemInstruction,
    bool jsonMode = false,
    double? temperature,
  }) async {
    developer.log(
      'Google AI Request - Model: $_modelName',
      name: 'GoogleAiDataSource',
    );

    final response = await _client.models.generateContent(
      model: _modelName,
      request: GenerateContentRequest(
        contents: [Content.text(prompt)],
        systemInstruction: Content.text(systemInstruction),
        generationConfig: GenerationConfig(
          responseMimeType: jsonMode ? 'application/json' : 'text/plain',
          temperature: temperature,
        ),
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('AI response was empty');
    }

    return text;
  }
}
