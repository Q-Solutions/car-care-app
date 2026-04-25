import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter/material.dart';

@lazySingleton
class SettingsService extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _currencyKey = 'currency';
  static const String _dateFormatKey = 'date_format';
  static const String _aiBaseUrlKey = 'ai_base_url';
  static const String _aiApiKeyKey = 'ai_api_key';
  static const String _aiModelKey = 'ai_model';

  late Box settingsBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    settingsBox = await Hive.openBox(_boxName);
    _isInitialized = true;
    debugPrint('SETTINGS_SERVICE: Initialized box. Current currency: ${currency}');
  }

  final _currencyController = StreamController<String>.broadcast();
  final _dateFormatController = StreamController<String>.broadcast();

  Stream<String> get currencyStream => _currencyController.stream;
  Stream<String> get dateFormatStream => _dateFormatController.stream;

  String get currency {
    if (!_isInitialized) return r'$';
    return settingsBox.get(_currencyKey, defaultValue: r'$');
  }
  
  Future<void> setCurrency(String value) async {
    debugPrint('SETTINGS_SERVICE: Saving currency: $value');
    await settingsBox.put(_currencyKey, value);
    _currencyController.add(value);
    notifyListeners();
  }

  String get dateFormat {
    if (!_isInitialized) return 'dd/MM/yyyy';
    return settingsBox.get(_dateFormatKey, defaultValue: 'dd/MM/yyyy');
  }

  Future<void> setDateFormat(String value) async {
    debugPrint('SETTINGS_SERVICE: Saving date format: $value');
    await settingsBox.put(_dateFormatKey, value);
    _dateFormatController.add(value);
    notifyListeners();
  }

  String get aiBaseUrl => settingsBox.get(_aiBaseUrlKey, defaultValue: '');
  Future<void> setAiBaseUrl(String value) async {
    await settingsBox.put(_aiBaseUrlKey, value);
    notifyListeners();
  }

  String get aiApiKey => settingsBox.get(_aiApiKeyKey, defaultValue: '');
  Future<void> setAiApiKey(String value) async {
    await settingsBox.put(_aiApiKeyKey, value);
    notifyListeners();
  }

  String get aiModel => settingsBox.get(_aiModelKey, defaultValue: '');
  Future<void> setAiModel(String value) async {
    await settingsBox.put(_aiModelKey, value);
    notifyListeners();
  }

  Future<void> detectAndSetCurrency() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        String? countryCode = placemarks.first.isoCountryCode;
        String currency = _mapCountryToCurrency(countryCode);
        await setCurrency(currency);
      }
    } catch (e) {
      debugPrint('Error detecting currency: $e');
    }
  }

  String _mapCountryToCurrency(String? countryCode) {
    switch (countryCode) {
      case 'IN': return '₹';
      case 'US': return r'$';
      case 'GB': return '£';
      case 'EU': return '€';
      case 'JP': return '¥';
      case 'PK': return 'Rs.';
      default: return r'$';
    }
  }

  @override
  @disposeMethod
  void dispose() {
    _currencyController.close();
    _dateFormatController.close();
    super.dispose();
  }
}
