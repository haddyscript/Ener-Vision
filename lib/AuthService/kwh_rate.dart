import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/AuthService/preferences.dart';

class KWHRateService {
  static Future<void> saveKwhRate(String kwhRate) async {
    final prefs = await SharedPreferences.getInstance();

    final String? userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/updateKwh/$userId');
    String? token = await getToken();

    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'kwhRate': kwhRate}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to save kWh rate');
    }
  }

  static Future<double?> getKwhRate() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/getUserKwhRate/$userId');

    String? token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is missing');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('KwhRate found: ${data['kwhRate']}');
        return (data['kwhRate'] as num).toDouble();
      } else if (response.statusCode == 404) {
        print('KwhRate not found for user.');
        return null; // Return null if not found
      } else {
        throw Exception(
            'Failed to load user kwhRate, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
