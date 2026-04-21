import 'package:flutter_test/flutter_test.dart';
import 'package:carlog/core/services/ai_service.dart';
import 'package:carlog/core/services/settings_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SettingsService])
import 'ai_parsing_test.mocks.dart';

void main() {
  late AIService aiService;
  late MockSettingsService mockSettings;

  setUp(() {
    mockSettings = MockSettingsService();
    // Default mock behavior
    when(mockSettings.aiBaseUrl).thenReturn('');
    aiService = AIService(mockSettings);
  });

  group('AIService.safeJsonParse', () {
    test('parses clean JSON from Gemini shared link', () {
      const raw = '''{ 
  "type": "refuel", 
  "name": "Classic Service Station", 
  "date": "2026-04-18", 
  "liter": 4.00, 
  "price_per_liter": 367.95, 
  "total_amount": 1471.80, 
  "currency": "Rs", 
  "odometer": null 
}''';
      final result = aiService.safeJsonParse(raw);
      expect(result, isNotNull);
      expect(result!['type'], 'refuel');
      expect(result['liter'], 4.0);
      expect(result['total_amount'], 1471.8);
    });

    test('extracts and parses JSON from markdown code block', () {
      const raw = '''Sure, here is the data:
```json
{
  "type": "store",
  "name": "Walmart",
  "total_amount": 50.25
}
```''';
      final result = aiService.safeJsonParse(raw);
      expect(result, isNotNull);
      expect(result!['type'], 'store');
      expect(result['name'], 'Walmart');
      expect(result['total_amount'], 50.25);
    });

    test('extracts JSON via brute force braces when text precedes it', () {
      const raw = '''Results: {
  "type": "mechanic",
  "name": "Quick Fix",
  "total_amount": 120.00
} Note: price is estimated.''';
      final result = aiService.safeJsonParse(raw);
      expect(result, isNotNull);
      expect(result!['type'], 'mechanic');
      expect(result['name'], 'Quick Fix');
    });

    test('returns null for truly invalid data', () {
      const raw = 'This is not JSON at all.';
      final result = aiService.safeJsonParse(raw);
      expect(result, isNull);
    });

    test('handles accidental spaces in keys or weird nesting if jsonDecode allows it', () {
      const raw = '   {"type": "refuel", "total_amount": 10.5 }   ';
      final result = aiService.safeJsonParse(raw);
      expect(result, isNotNull);
      expect(result!['total_amount'], 10.5);
    });
  });
}
