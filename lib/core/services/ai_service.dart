import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

@lazySingleton
class AIService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _modelName = 'gemini-1.5-flash';

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Map<String, dynamic>?> analyzeReceiptText(String text, String receiptType) async {
    if (_apiKey.isEmpty) {
      debugPrint('WARNING: GEMINI_API_KEY is not set. AI parsing will not work.');
      return null;
    }

    final prompt = _getPromptForType(receiptType, text);

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        return jsonDecode(response.text!) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error during AI receipt analysis: $e');
    }
    return null;
  }

  String _getPromptForType(String type, String text) {
    switch (type) {
      case 'fuel':
        return '''
        Analyze the following text from a fuel/gas station receipt and extract the data into a JSON object.
        JSON format:
        {
          "stationName": "string or null",
          "totalAmount": number or null,
          "liters": number or null,
          "pricePerLiter": number or null,
          "location": "string or null"
        }
        Text:
        $text
        ''';
      case 'store':
        return '''
        Analyze the following text from a store/POS receipt and extract the data into a JSON object.
        JSON format:
        {
          "storeName": "string or null",
          "items": [
            {
              "name": "string",
              "quantity": number,
              "price": number
            }
          ],
          "totalAmount": number or null
        }
        Text:
        $text
        ''';
      case 'mechanic':
        return '''
        Analyze the following text from a mechanic or vehicle repair bill and extract the data into a JSON object.
        JSON format:
        {
          "mechanicName": "string or null",
          "services": [
            {
              "description": "string",
              "cost": number
            }
          ],
          "totalAmount": number or null
        }
        Text:
        $text
        ''';
      default:
        return 'Analyze this text and extract any meaningful receipt data into JSON: $text';
    }
  }
}
