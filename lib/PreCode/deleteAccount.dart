import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final List<String> reasons = [
    "No longer using the service/platform",
    "Found a better alternative",
    "Privacy concerns",
    "Too many procedures.",
    "Difficulty navigating the platform",
    "Account security concerns",
    "Personal reasons",
    "Others",
  ];

  String? selectedReason;
  final TextEditingController otherReasonController = TextEditingController();
  final String apiUrl = 'http://10.0.2.2:8080';
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) {
      _showResultDialog('Error', "User is not logged in. Please log in again.");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Display dialog with the result of an action
  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Delete user account method
  Future<void> deleteUserAccount() async {
    if (userId == null) {
      _showResultDialog('Error', "User ID is not available. Please log in.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/delete-account/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reason': selectedReason,
          'otherReason': otherReasonController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showResultDialog('Success', 'Account deleted successfully.');

        final prefs = await SharedPreferences.getInstance();
        prefs.remove('userId');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      } else {
        _showResultDialog(
            'Error', responseData['message'] ?? 'Failed to delete account');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $error')),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: Color(0xFF1BBC9B), size: 50),
                const SizedBox(height: 20),
                const Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Deleting your account is permanent and will erase all data and settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[700],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Keep Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteUserAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1BBC9B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteButtonPress() {
    if (selectedReason == null ||
        (selectedReason == "Others" && otherReasonController.text.isEmpty)) {
      _showResultDialog('Error',
          'Please select or provide a reason for deleting your account.');
    } else {
      _showConfirmationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar1(
          onBackPressed: () {
            Navigator.pop(context);
          },
          showProfile: false,
          showTitle: false),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 25.0, bottom: 25.0, right: 25.0, top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delete Account',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            const Text(
              "If you need to delete an account, please provide a reason.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(reasons[index],
                        style: const TextStyle(fontSize: 15.0)),
                    value: reasons[index],
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                        if (selectedReason != "Others") {
                          otherReasonController.clear();
                        }
                      });
                    },
                    activeColor: const Color(0xFF1BBC9B),
                  );
                },
              ),
            ),
            if (selectedReason == "Others")
              TextField(
                controller: otherReasonController,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: "Write a reason here...",
                  labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                      fontSize: 13.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF1BBC9B), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF1BBC9B), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _handleDeleteButtonPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBC9B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(500, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
