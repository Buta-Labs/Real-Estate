import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  static const String _apiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  /// Fetch current USD to AZN exchange rate
  static Future<double> getUsdToAznRate() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return (rates['AZN'] as num?)?.toDouble() ?? 1.70; // Default fallback
      }
    } catch (e) {
      debugPrint('Error fetching currency rate: $e');
    }
    return 1.70; // Fallback rate
  }

  /// Convert USD to AZN
  static Future<double> usdToAzn(double usdAmount) async {
    final rate = await getUsdToAznRate();
    return usdAmount * rate;
  }

  /// Convert AZN to USD
  static Future<double> aznToUsd(double aznAmount) async {
    final rate = await getUsdToAznRate();
    return aznAmount / rate;
  }

  /// Calculate 30-day volatility (simplified - would need historical data API)
  static Future<double> getVolatility() async {
    // Placeholder - in production, fetch historical rates and calculate std deviation
    return 2.3; // ±2.3% as mentioned in the plan
  }
}
