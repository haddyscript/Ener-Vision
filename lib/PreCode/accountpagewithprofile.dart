import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/PreCode/change_password.dart';
import 'package:supabase_project/PreCode/deleteAccount.dart';

import '../AuthService/services/user_service.dart';
class ProfilePageNew extends StatefulWidget {
  @override
  _ProfilePageNewState createState() => _ProfilePageNewState();
}

class _ProfilePageNewState extends State<ProfilePageNew> {
  bool isUserLoaded = false;
  String? userId;
  String name = '';
  String mobileNumber = '';
  String email = '';
  String birthDate = '';
  String address = '';
  String avatarUrl = ''; // To store avatar URL
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? loadedUserId = await UserService.getUserId();

    if (loadedUserId != null) {
      setState(() {
        userId = loadedUserId; // Update the state with the userId
      });
      print('User ID Loaded: $userId');
      _fetchUserData(); // Now you can safely fetch the user data
    } else {
      setState(() {
        isUserLoaded = false;
        errorMessage = 'User ID not found. Please log in again.';
      });
    }
  }

  Future<void> _fetchUserData() async {
    if (userId == null) {
      setState(() {
        errorMessage = 'User ID is missing.';
        isUserLoaded = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/userProfileLatest/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final addressData = data['address'];
        final formattedAddress = addressData != null
            ? '${addressData['countryLine']}, ${addressData['cityLine']}, ${addressData['streetLine']}'
            : 'N/A';

        String formattedBirthDate = 'N/A';
        if (data['birthDate'] != null) {
          DateTime birthDateTime = DateTime.parse(data['birthDate']);
          birthDateTime = birthDateTime.toLocal();
          formattedBirthDate = DateFormat('MMM dd, yyyy').format(birthDateTime);
        }

        setState(() {
          name = data['name'] ?? 'N/A';
          email = data['email'] ?? 'N/A';
          mobileNumber = data['mobileNumber'] ?? 'N/A';
          birthDate = formattedBirthDate;
          address = formattedAddress;
          avatarUrl = data['avatar'] ?? ''; // Assign avatar URL
          isUserLoaded = true;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user data. Status Code: ${response.statusCode}';
          isUserLoaded = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching user data: $error';
        isUserLoaded = false;
      });
    }
  }

  void _pickNewAvatar() async {
    // Here you can implement functionality to allow the user to pick a new avatar
    // For example, using an image picker package
    // After picking the image, you would upload it and update the avatarUrl
    // You might also need to call _fetchUserData() again to refresh the profile
  }

  @override
  Widget build(BuildContext context) {
    const customColor = Color(0xFF1BBC9B);
    const darkerRed = Color(0xFFEF5350);
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar1(
        showProfile: false,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 2),

      backgroundColor: customColor,
      body: Column(
        children: [
          isUserLoaded
              ? Stack(
            alignment: Alignment.center,
            children: [
              // Use FadeInImage to handle loading and error states
              FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder.png', // Add a placeholder image in your assets folder
                image: avatarUrl.isNotEmpty ? '${ApiConfig.baseUrl}/$avatarUrl' : 'https://via.placeholder.com/150',
                imageErrorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  );
                },
                fadeInDuration: Duration(milliseconds: 200),
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: _pickNewAvatar, // Action when the camera icon is tapped
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          )
              : Center(
            child: errorMessage.isNotEmpty
                ? Text(errorMessage, style: TextStyle(color: Colors.red))
                : CircularProgressIndicator(),
          ),
          SizedBox(height: 20),
          // Add the rest of the profile information here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $name', style: TextStyle(fontSize: 18)),
                Text('Email: $email', style: TextStyle(fontSize: 18)),
                Text('Mobile: $mobileNumber', style: TextStyle(fontSize: 18)),
                Text('Birth Date: $birthDate', style: TextStyle(fontSize: 18)),
                Text('Address: $address', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFF1BBC9B),
                width: 1.0,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: color),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color borderColor;

  DeleteButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: borderColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: borderColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
