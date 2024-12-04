import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/preferences.dart';
import 'package:supabase_project/AuthService/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/loading_page.dart';
import 'package:supabase_project/MainFolder/secondaryMain.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:flutter/foundation.dart';

import '../EnergyManagement/Community/energy_effieciency_page.dart';
import '../SignUpLogin&LandingPage/setup_profile.dart';
import 'base_url.dart';

class AuthService {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? usernameController;
  final TextEditingController? kwhRateController;

  AuthService({
    required this.context,
    required this.emailController,
    required this.passwordController,
    this.usernameController,
    this.kwhRateController,
  });
  Future<String?> fetchUserProfilePhoto(String userId) async {
    final response = await http.get(
      Uri.parse('http://yourapi.com/getUserProfile?userId=$userId'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON and extract the photo URL
      final profileData = jsonDecode(response.body);
      return profileData[
          'photoUrl']; // Change this based on your API's response structure
    } else if (response.statusCode == 404) {
      print('User profile not found');
      return null;
    } else {
      throw Exception('Failed to load user profile photo');
    }
  }

  Future<http.Response?> signUp() async {
    // String apiUrl =
    //     kReleaseMode ? "http://10.0.2.2:8080/" : "http://192.168.1.217:8080/";
    // final url = Uri.parse("${apiUrl}signup");
    // final url = Uri.parse("http://192.168.1.217/signup");

    final url = Uri.parse("${ApiConfig.baseUrl}/signup");

    try {
      String username = toTitleCase(usernameController?.text ?? '');

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
          'username': username,
        }),
      );

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        final token = responseBody['token'];

        String userId = responseBody['user']['_id'];
        if (token != null) {
          await saveToken(token);
        }
        // Save the user ID to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SetupProfile()),
        );
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Email is not available';
        print('Error: $errorMessage');
      } else {
        print('Failed to Sign in: ${response.body}');
      }

      return response; // Return the response to handle it in the calling function
    } catch (e) {
      print('Error occurred while signing up: $e');
      return null; // Return null in case of an error
    }
  }

  Future<http.Response?> signIn() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/signin");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody != null &&
            responseBody['user'] != null &&
            responseBody['user']['_id'] != null) {
          String userId = responseBody['user']['_id'];
          String username = responseBody['user']['username'] ?? "Guest";
          final token = responseBody['token'];
          bool hasProfile = responseBody['user']['hasProfile'] ?? false;

          if (token != null) {
            await saveToken(token);
          }

          // Save the user ID and username to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setString('username', username);

          // Navigate based on the profile existence
          if (hasProfile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EnergyEfficiencyPage(
                  selectedIndex: 0,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SetupProfile()),
            );
          }
        } else {
          throw Exception('User ID not found in response: ${response.body}');
        }
      } else if (response.statusCode == 401) {
        return response;
      } else {
        throw Exception('Failed to Sign in: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while signing in: $e');
    }

    return null;
  }

  Future<void> fetchUserProfile(String userId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/getAvatar/$userId");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var profileData = jsonDecode(response.body);
        String birthDate = profileData['birthDate'];

        // Calculate age
        DateTime birth = DateTime.parse(birthDate);
        int age = DateTime.now().year - birth.year;
        if (DateTime.now()
            .isBefore(DateTime(birth.year, birth.month, birth.day))) {
          age--;
        }

        print('User age: $age');
      } else {
        print('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while fetching user profile: $e');
    }
  }
}
