import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';

class PasswordResetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          showBackArrow: true,
          showTitle: false,
          showProfile: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  const Text(
                    'Change your password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Must be different from previous passwords.',
                    style: TextStyle(
                      color: Color(0xFF000000), // Light black
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 30),
                  PasswordResetForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordResetForm extends StatefulWidget {
  @override
  _PasswordResetFormState createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  final _formKey = GlobalKey<FormState>();
  String? oldPassword;
  String? newPassword;
  String? confirmPassword;

  // Password validation logic
  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value == oldPassword) {
      return 'New password cannot be the same as the old password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Old Password
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Old Password',
              labelStyle: const TextStyle(
                color: Color(0xFFB9BCC5),
                fontFamily: 'Montserrat',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF61C7A9)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF61C7A9), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              setState(() {
                oldPassword = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your old password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // New Password
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Enter New Password',
              labelStyle: const TextStyle(
                color: Color(0xFFB9BCC5),
                fontFamily: 'Montserrat',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF61C7A9)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF61C7A9), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              setState(() {
                newPassword = value;
              });
            },
            validator: (value) => validatePassword(value!),
          ),
          const SizedBox(height: 20),

          // Confirm New Password
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              labelStyle: const TextStyle(
                color: Color(0xFFB9BCC5),
                fontFamily: 'Montserrat',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF61C7A9)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF61C7A9), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              setState(() {
                confirmPassword = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != newPassword) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Reset Password button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF61C7A9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Perform password reset logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password successfully reset!')),
                );
              }
            },
            child: const Text(
              'Reset Password',
              style: TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
