import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_project/AuthService/preferences.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';

import 'base_url.dart';

class SuggestionService {
  static Future<void> addSuggestion({
    required BuildContext context,
    required TextEditingController suggestionController,
    required List<dynamic> posts,
    required int index,
  }) async {
    final suggestionText = suggestionController.text.trim();

    if (suggestionText.isEmpty) {
      showSnackBar(context, 'Suggestion text cannot be empty');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        showSnackBar(context, 'User not logged in');
        return;
      }

      final postId = posts[index]['id'] ?? posts[index]['_id'];

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/addSuggestionToPost/$postId/suggestions');
      final body = jsonEncode({
        'userId': userId,
        'suggestionText': suggestionText,
      });

      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        showSnackBar(context, 'Suggestion added successfully to $postId');
        print('Suggestion added successfully to $postId');
        suggestionController.clear(); // Clear the text field
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context, 'Failed to add suggestion: ${responseData['message']}');
      }
    } catch (e) {
      print('$e');
      showSnackBar(context, 'An error occurred: $e');
    }
  }

  static Future<void> addSuggestionNew({
    required BuildContext context,
    required TextEditingController suggestionController,
    required List<dynamic> posts,
    required String postId,
  }) async {
    final suggestionText = suggestionController.text.trim();

    if (suggestionText.isEmpty) {
      showSnackBar(context, 'Suggestion text cannot be empty');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        showSnackBar(context, 'User not logged in');
        return;
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/addSuggestionToPost/$postId/suggestions');
      final body = jsonEncode({
        'userId': userId,
        'suggestionText': suggestionText,
      });

      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        showSnackBar(context, 'Suggestion added successfully to $postId');
        print('Suggestion added successfully to $postId');
        suggestionController.clear(); // Clear the text field
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context, 'Failed to add suggestion: ${responseData['message']}');
      }
    } catch (e) {
      print('$e');
      showSnackBar(context, 'An error occurred: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/getAllPostsSuggestions/$postId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } catch (e) {
        throw Exception('Failed to parse suggestions data');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Suggestions not found');
    } else {
      throw Exception('Failed to load suggestions: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> getPostSuggestions(String postId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/getPostSuggestions/$postId');
    print('Sending Fetch request to: $url');
    // String? token = await getToken();
    // if (token != null) {
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      print('Post with ID $postId retrieved successfully.');
      final postData = jsonDecode(response.body); // parse the post data
      return postData; // return the fetched post data
    } else {
      final responseBody = jsonDecode(response.body);
      print('Failed to fetch post. Server response: ${response.body}');
      throw Exception('Failed to fetch post: ${responseBody['message']}');
    }
  }

  static Future<void> deleteSuggestion(String suggestionId) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/deleteSuggestion/$suggestionId'); // Correct endpoint
    String? token = await getToken();

    if (token == null) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Suggestion deleted successfully'); // Optional logging
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(
          'Failed to delete suggestion: ${responseBody['message'] ?? 'Unknown error'}');
    }
  }
}
