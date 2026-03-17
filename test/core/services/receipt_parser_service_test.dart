import 'package:flutter_test/flutter_test.dart';
import 'package:carlog/core/services/receipt_parser_service.dart';
import 'package:carlog/core/services/ai_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'receipt_parser_service_test.mocks.dart';

@GenerateMocks([AIService])
void main() {
  late ReceiptParserService service;
  late MockAIService mockAiService;

  setUp(() {
    mockAiService = MockAIService();
    service = ReceiptParserService(mockAiService);
    
    // Default: AI returns null (falls back to regex)
    when(mockAiService.analyzeReceiptText(any, any)).thenAnswer((_) async => null);
  });

  group('ReceiptType Detection', () {
    test('detects fuel receipt from petrol keywords', () {
      const text = '''
HP PETROL PUMP
Station Road, Lahore
Date: 15/03/2026
Petrol - Premium
Qty: 15.5 Ltr
Rate: Rs. 272.45/Ltr
Amount: Rs. 4,223
''';
      expect(service.detectReceiptType(text), ReceiptType.fuel);
    });

    test('detects fuel receipt from fuel brand names', () {
      const text = '''
SHELL FILLING STATION
Total Amount: 3500
Volume: 12.5 L
''';
      expect(service.detectReceiptType(text), ReceiptType.fuel);
    });

    test('detects POS receipt from store keywords', () {
      const text = '''
AUTO PARTS STORE
Invoice #12345
Oil Filter        Rs. 350
Air Filter        Rs. 250
Subtotal          Rs. 600
GST               Rs. 108
Total             Rs. 708
Payment: Cash
''';
      expect(service.detectReceiptType(text), ReceiptType.pos);
    });

    test('detects mechanic bill from repair keywords', () {
      const text = '''
KHAN MOTOR WORKSHOP
Service Bill
Oil Change        Rs. 800
Labour Charge     Rs. 500
Brake Pad Replacement Rs. 2000
Total             Rs. 3300
''';
      expect(service.detectReceiptType(text), ReceiptType.mechanic);
    });
  });

  group('Fuel Receipt Parsing', () {
    test('extracts station name from known brand', () async {
      const text = '''
HP PETROLEUM
Main Road, Islamabad
Rate: 272.45
Qty: 20.5 Ltr
Amount: Rs. 5,585
''';
      final result = await service.parseFuelReceipt(text);
      expect(result.stationName, contains('HP'));
    });

    test('extracts total amount from "Amount" keyword', () async {
      const text = '''
SHELL STATION
Amount: Rs. 3,500.00
Volume: 12.5 Ltr
''';
      final result = await service.parseFuelReceipt(text);
      expect(result.totalAmount, 3500.0);
    });

    test('extracts liters from "Ltr" suffix', () async {
      const text = '''
PETROL PUMP
15.5 Ltr Petrol
Total: Rs. 4223
''';
      final result = await service.parseFuelReceipt(text);
      expect(result.liters, 15.5);
    });

    test('AI parsing takes precedence', () async {
      const text = 'Random Text';
      when(mockAiService.analyzeReceiptText(any, 'fuel')).thenAnswer((_) async => {
        'stationName': 'AI Station',
        'totalAmount': 5000.0,
        'liters': 20.0,
      });

      final result = await service.parseFuelReceipt(text);
      expect(result.stationName, 'AI Station');
      expect(result.totalAmount, 5000.0);
      expect(result.liters, 20.0);
    });
  });

  group('POS Receipt Parsing', () {
    test('extracts items via AI', () async {
      const text = 'Store Receipt';
      when(mockAiService.analyzeReceiptText(any, 'store')).thenAnswer((_) async => {
        'items': [
          {'name': 'Oil Filter', 'quantity': 1, 'price': 350.0},
          {'name': 'Air Filter', 'quantity': 1, 'price': 250.0},
        ]
      });

      final items = await service.parsePOSReceipt(text);
      expect(items.length, 2);
      expect(items[0].name, 'Oil Filter');
    });

    test('falls back to regex when AI fails', () async {
      const text = '''
STORE
Item A        100.00
Item B        200.00
''';
      final items = await service.parsePOSReceipt(text);
      expect(items.length, greaterThanOrEqualTo(2));
    });
  });

  group('Mechanic Bill Parsing', () {
    test('extracts services via AI', () async {
      const text = 'Mechanic Bill';
      when(mockAiService.analyzeReceiptText(any, 'mechanic')).thenAnswer((_) async => {
        'services': [
          {'description': 'Oil Change', 'cost': 800.0},
        ]
      });

      final services = await service.parseMechanicBill(text);
      expect(services.length, 1);
      expect(services[0].description, 'Oil Change');
    });

    test('falls back to regex when AI fails', () async {
      const text = '''
Bill
Service X     500.00
''';
      final services = await service.parseMechanicBill(text);
      expect(services.length, greaterThanOrEqualTo(1));
    });
  });
}
