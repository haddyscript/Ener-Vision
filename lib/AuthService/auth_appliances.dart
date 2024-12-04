import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/AuthService/preferences.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';

class ApplianceService {
  static Future<void> addAppliance(
      String userId, Map<String, dynamic> applianceData) async {
    String? token = await getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/addApplianceNewLogic');
    if (token != null) {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'userId': userId,
          'applianceData': applianceData,
        }),
      );
      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('Appliance added: ${responseBody['appliance']}');
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to add appliance: ${responseBody['error']}');
      } else {
        throw Exception('Unexpected error: ${response.body}');
      }
    }
  }

  static Future<Map<String, dynamic>> fetchTodayAppliance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/getAllTodayAppliances/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the response body as a Map
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Ensure data types are correctly parsed
      return {
        'appliances':
            List<Map<String, dynamic>>.from(responseData['appliances'] ?? []),
        'totalDailyConsumptionCost': double.tryParse(
                responseData['totalDailyConsumptionCost']?.toString() ?? '0') ??
            0.0,
        'totalDailyKwhConsumption': double.tryParse(
                responseData['totalDailyKwhConsumption']?.toString() ?? '0') ??
            0.0,
        'totalDailyCO2Emissions': double.tryParse(
                responseData['totalDailyCO2Emissions']?.toString() ?? '0') ??
            0.0,
      };
    } else if (response.statusCode == 404) {
      throw Exception('Appliances not found');
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  // Static method to Read appliances
  static Future<List<Map<String, dynamic>>> fetchAppliance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/getAllUsersAppliances/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Returning the decoded response body
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Appliances not found');
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAppliance1() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/getAllUsersAppliances/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the response body
      List<dynamic> responseData = jsonDecode(response.body);

      // Map the data to only include applianceName and monthlyCost
      List<Map<String, dynamic>> appliances = responseData.map((appliance) {
        return {
          'applianceName': appliance['applianceName'],
          'monthlyCost': appliance['monthlyCost'],
        };
      }).toList();

      return appliances;
    } else if (response.statusCode == 404) {
      throw Exception('Appliances not found');
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  static Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updatedData) async {
    if (updatedData.containsKey('applianceName')) {
      updatedData['applianceName'] = toTitleCase(updatedData['applianceName']);
    }

    // Prepare the updated data to include required fields
    final updates = {
      'updatedAt': DateTime.now().toIso8601String(),
      'updatedData': updatedData,
    };

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/updateApplianceOccurrences/$applianceId');
    String? token = await getToken();
    if (token != null) {
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody; // Return response if needed
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to update appliance: ${responseBody['error']}');
      }
    }
  }

  // Static method to delete an appliance
  static Future<void> deleteAppliance(String applianceId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/deleteAppliance/$applianceId');
    String? token = await getToken();
    if (token != null) {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(
            'Failed to delete appliance: ${responseBody['message']}');
      }
    }
  }

  // Static method to add to monthly consumption

  Future<Map<String, String>?> getDaily() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId');

    if (userId == null) {
      return null;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/totalDailyData/$userId');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safely parse the totalDailyConsumptionCost and totalDailyKwhConsumption
        final totalDailyConsumptionCost =
            double.tryParse(data['totalDailyConsumptionCost'].toString()) ??
                0.00;
        final totalDailyKwhConsumption =
            double.tryParse(data['totalDailyKwhConsumption'].toString()) ??
                0.00;

        return {
          'totalDailyConsumptionCost':
              totalDailyConsumptionCost.toStringAsFixed(2),
          'totalDailyKwhConsumption':
              totalDailyKwhConsumption.toStringAsFixed(2),
        };
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<void> deletePost(String postId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/deletePost/$postId');
    print('Sending DELETE request to: $url');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Post with ID $postId deleted successfully.');
    } else {
      final responseBody = jsonDecode(response.body);
      print('Failed to delete appliance. Server response: ${response.body}');
      throw Exception('Failed to delete appliance: ${responseBody['message']}');
    }
  }

  static Future<void> addSuggestionToAPost(
      String postId, Map<String, dynamic> suggestionData) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/addSuggestions/$postId');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'suggestionData': suggestionData,
      }),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Suggestion added: ${responseBody['newSuggestion']}');
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add suggestion: ${responseBody['message']}');
    } else if (response.statusCode == 404) {
      throw Exception('Post not found: ${response.body}');
    } else {
      throw Exception('Unexpected error: ${response.body}');
    }
  }
}
