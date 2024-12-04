import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/AuthService/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/loading_page.dart';
import 'package:supabase_project/CommonWidgets/textfield.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/setup_profile.dart';
import 'package:supabase_project/ConstantTexts/user.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/buttons/login_signUp.dart';

import 'package:wc_form_validators/wc_form_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final AppControllers controllers = AppControllers();
  bool _isPasswordVisible = false;

  bool _showClearIcon = false;
  bool _isLoading = false;

  User user = User('', '', '');
  @override
  void dispose() {
    controllers.usernameController.dispose();
    controllers.emailController.dispose();
    controllers.passwordController.dispose();
    super.dispose();
  }

  Future<Object?> _showErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Registration Error',
      message:
          "The email is already registered.\nPlease use a different email.",
      buttonText: 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_isLoading)
                const Center(
                  child: LoadingWidget(
                    message: 'Logging in...',
                    color: AppColors.primaryColor,
                  ),
                ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15.0),
                      const Image(
                        image: AssetImage('assets/login.png'),
                        width: 500.0,
                        height: 300.0,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Become a member!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Enter your credentials to continue',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: controllers.usernameController,
                              hintText: 'Username',
                              keyboardType: TextInputType.text,
                              prefixIcon: const Icon(Icons.person_outlined),
                              obscureText: false,
                              onChanged: (value) {
                                setState(() {
                                  _showClearIcon = value.isNotEmpty;
                                });
                                user.password = value;
                              },
                              validator: Validators.compose([
                                Validators.required('Username is required'),
                              ]),
                              placeholderText: 'Username',
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: controllers.emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              prefixIcon: const Icon(Icons.email_outlined),
                              onChanged: (value) {
                                setState(() {
                                  _showClearIcon = value.isNotEmpty;
                                });
                                user.email = value;
                              },
                              validator: Validators.compose([
                                Validators.required('Email is required'),
                                Validators.patternString(
                                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                                    'Enter Valid Email')
                              ]),
                              placeholderText: '123@gmail.com',
                            ),
                            const SizedBox(height: 20),
                            PasswordField(
                              controller: controllers.passwordController,
                              hintText: 'Password',
                              // keyboardType: TextInputType.text,
                              prefixIcon: const Icon(Icons.lock_outline),
                              // obscureText: true,
                              onChanged: (value) {
                                setState(() {
                                  _showClearIcon = value.isNotEmpty;
                                });
                                user.password = value;
                              },
                              placeholder: "Passw0rd!",
                              // validator: Validators.compose([
                              //   Validators.required('Password is required'),
                              //   Validators.patternString(
                              //       r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                              //       'Password must be at least 8 characters long \n Must have at least one special character\n Must have at least one Uppercase character')
                              // ]),
                            ),
                            const SizedBox(height: 50),
                            SignUpButton(
                              onPressed: () async {
                                // Trigger field validation
                                bool isFormValid =
                                    _formKey.currentState?.validate() ?? false;

                                if (isFormValid) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final response = await AuthService(
                                      context: context,
                                      emailController:
                                          controllers.emailController,
                                      passwordController:
                                          controllers.passwordController,
                                      usernameController:
                                          controllers.usernameController,
                                    ).signUp();

                                    if (response != null) {
                                      if (response.statusCode == 400) {
                                        await _showErrorDialog(context);
                                      } else if (response.statusCode == 201) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SetupProfile()),
                                        );
                                      }
                                    } else {
                                      SnackBarHelper.showSnackBar(
                                          context, 'Internal Server Error');
                                    }
                                  } catch (e) {
                                    SnackBarHelper.showSnackBar(
                                        context, 'An error occurred');
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                } else {
                                  // Display error snack bar
                                  SnackBarHelper.showSnackBar(
                                      context, 'Please fill in all fields.');
                                }
                              },
                              text: 'Register',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PositionedButton(
                top: 20,
                right: 15,
                buttonText: 'Login',
                targetPage: LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
