import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/PreCode/change_password.dart';
import 'package:supabase_project/PreCode/deleteAccount.dart';

import '../AuthService/services/user_service.dart';
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String apiUrl = 'http://10.0.2.2:8080';
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
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (loadedUserId != null) {
      setState(() {
        userId = loadedUserId;
      });
      print('User ID Loaded: $userId');
      _fetchUserData();
    } else {
      setState(() {
        isUserLoaded = false;
        errorMessage = 'User ID not found. Please log in again.';
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/userProfileLatest/$userId'));

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
          errorMessage =
              'Failed to load user data. Status Code: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    const customColor = Color(0xFF1BBC9B);
    const darkerRed = Color(0xFFEF5350);
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar3(
        showProfile: false,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: customColor,
      body: Column(
        children: [
          // User avatar display with error handling
          isUserLoaded
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder:
                          'assets/profile.jpg', // Add a placeholder image in your assets folder
                      image: avatarUrl.isNotEmpty
                          ? (avatarUrl.startsWith('http')
                              ? avatarUrl
                              : '${ApiConfig.baseUrl}/$avatarUrl')
                          : 'https://via.placeholder.com/150',
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAflBMVEX///9fyfhax/gxufYHW50EWZwDWJxPxfjz+/4IXJ5hhrSi3ftVxvjd5e4AVJrX8P3n9v5HvveG0/nN7P0AT5jf8/140PkATJcARpTS7v245fvE6Py2xtro9v4tqucMs/UARJNOrOAIO4uW2fotu/au3/oGOYnC4PNSfK7v8/fVukePAAADUklEQVR4nO3c21LbMBSFYSuxJVJSUVqDTaEmoS1t3/8F6wNxEluytzvTyd6b9Q+XXPibJaIhHJIEIYQQQgghhBBCCCGEEEIIIYQQQggp6eZ6Qd+vLv24y3twW2rOuZtLP+7yHpwJtQqmCBgWagIGhaqAIaFE4E0UGBAqA46F2oAjoTrgUKgPaOQD46+iAaFGoFEPNOqBRj3QqAca9UCjHmgAZBsRaNQDjXqgUQ806oEGQI4BCCDzvgAIIO8ABJB5AALIPADfE9C4u0s/7vKWAdUvqB6II8ovLAgg8wAEkHkAAsg8AAFkHoAAMg9AAJkHIIDMAxDAuqtFCQTeO3q395yBnyLA7egv8aK5zwAC+L+AK4nAO+3AJPlK/7V0mUA6USyQShQMpBFFAylE4cB5onjgHFEBcJqoAjhFVAKME9UAY8SV+xb+dHnAMDG64K2L/BMoxsAQMQ5cr7dUIh/gmBg9ojWQTOQEHBKnFiQTeQHPiXNAEpEb8JQ4fUSJRH7AI3F+wZYoD3gg0oAzRJ7Ajkg5ol1OHrAhUhecJPIFNkQ6MErkDEySyA9OgsAIkTcwUgQYJOoCBojagCOiPuCAKBK4mgaeEUUC72cmPCXKBG7nhQeiUKAhCDuiUOBqRRE2RLFAmnDtRAJN+w0STbiWCEweHV1Y+Y+Xftx/qSWShFWW5WKJFGGVpRu5RIKwsulmI5c4L+yAcok/qECxxJ/PM0CfHYRSideTxMrb7EBMU6uP2ADfiGmTOmKVe9sSsw6YpsoOag30B2KqkVgV3rdEq5RYlXneEX1r7ImFEmIDjBBlrji8F6uyyHui9z2vfUWVueI5sdoVnbA1nvnqr0mhxMfj+4Zm/1IUb0Rv03QArIkyD2pPrIFl0Zb7/iY88Ylf0exfy7KoP4a8I1A2sVmw5uXZZug7AUo+qO2CuR3zznySV9y/BnkjoFjir5c0xBv75BKfdjSg4HvxqSQNKHrFctYn/V48J0YHVEKc2E8FMbSaknvxqczmzqcCImXABmh1EUNAscQdYcAOKJY4v6LtU0q0VjyxP6gTB9R2b6hKJZY25hsABRMjvhEwy7xQ4s6Ty3cyiR8W9PvPpR8XIYQQQgghhBBCCCGEEEIIIYQQQui99xd9MndVczNj5wAAAABJRU5ErkJggg=='),
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
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
          SizedBox(height: 20),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 10),
          // User data display
          if (isUserLoaded)
            Text(
              name,
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )
          else if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(
                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
            )
          else
            const CircularProgressIndicator(),
          const SizedBox(height: 5),
          if (isUserLoaded)
            Text(
              '+$mobileNumber',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          const SizedBox(height: 20),
          // Profile fields and action buttons
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isUserLoaded) const SizedBox(height: 20.0),
                    ProfileField(label: 'Email', value: email),
                    if (isUserLoaded) const SizedBox(height: 10.0),
                    ProfileField(label: 'Date Of Birth', value: birthDate),
                    if (isUserLoaded) const SizedBox(height: 10.0),
                    ProfileField(label: 'Address', value: address),
                    SizedBox(height: deviceHeight * 0.1),
                    ActionButton(
                      icon: Icons.lock,
                      label: 'Change Password',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PasswordResetApp()));
                      },
                      color: customColor,
                    ),
                    ActionButton(
                      icon: Icons.favorite,
                      label: 'My Appliance',
                      onTap: () {},
                      color: customColor,
                    ),
                    DeleteButton(
                      icon: Icons.delete,
                      label: 'Delete Account',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DeleteAccountPage()));
                      },
                      borderColor: darkerRed,
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
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
