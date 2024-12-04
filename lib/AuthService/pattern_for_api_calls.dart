import 'dart:convert';

import 'preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> someApiCall() async {
  final url = Uri.parse("http://yourapi.com/someEndpoint");

  // Retrieve token
  String? token = await getToken();

  if (token != null) {
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Add the Bearer token in the header
      },
      body: jsonEncode({
        'key': 'value', // Add your body data here
      }),
    );

    if (response.statusCode == 200) {
      // Handle success
      print("API call success!");
    } else {
      // Handle error (e.g., unauthorized, token expired)
      if (response.statusCode == 401) {
        print("Token expired or invalid. Please log in again.");
        // You can handle token expiry by asking the user to log in again
      }
    }
  } else {
    print("Token not found. Please log in.");
    // Handle case where no token is found (e.g., prompt user to log in)
  }
}
