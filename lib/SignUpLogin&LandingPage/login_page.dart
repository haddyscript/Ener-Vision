import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/EnergyPage/offline_calculator.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';
import 'package:supabase_project/ConstantTexts/user.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:supabase_project/buttons/login_signUp.dart';
import 'package:supabase_project/CommonWidgets/textfield.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showClearPasswordIcon = false;
  bool _showClearEmailIcon = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _onButtonPressed() async {
    if (!_isButtonEnabled) return;

    setState(() {
      _isButtonEnabled = false;
    });

    try {
      // Ensure _formKey.currentState is not null
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        try {
          final response = await AuthService(
            context: context,
            emailController: _emailController,
            passwordController: _passwordController,
          ).signIn();

          if (response != null) {
            if (response.statusCode == 401) {
              await _showErrorDialog(context);
            } else if (response.statusCode == 200) {
              _showSnackBar('Sign In Successful!');
            }
          }
        } catch (e) {
          print('Error during sign in: ${e.toString()}');
        }
      } else {
        await _emptyErrorDialog(context);

        print('Form validation failed.');
      }

      print("Button tapped!");
    } finally {
      setState(() {
        _isButtonEnabled = true;
      });
    }
  }

  User user = User('', '', '');
  Future<Object?> _showErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Login Failed',
      message: "Email or Password \nis incorrect",
      buttonText: 'OK',
    );
  }

  Future<Object?> _emptyErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Login Failed',
      message: "Input was empty",
      buttonText: 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        // appBar: AppBar(title: const Text('Login')),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Image(
                        image: AssetImage('assets/sign-up.png'),
                        width: 500.0,
                        height: 250.0,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Enter your email and password',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        prefixIcon: const Icon(Icons.email_outlined),
                        onChanged: (value) {
                          setState(() {
                            _showClearEmailIcon = value.isNotEmpty;
                          });
                          user.email = value;
                        },
                        validator: Validators.compose([
                          Validators.required('Email is required'),
                          // Validators.patternString(
                          //     r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                          //     'Enter Valid Email')
                        ]),
                        placeholderText: '123@gmail.com',
                      ),
                      const SizedBox(height: 20),
                      PasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        // keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.lock_outline),
                        // obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            _showClearPasswordIcon = value.isNotEmpty;
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
                      // Row(
                      //   children: [
                      //     // GestureDetector(
                      //     //   onTap: () {},
                      //     //   child: const Icon(
                      //     //     Icons.toggle_off_outlined,
                      //     //     color: Colors.greenAccent,
                      //     //     size: 25.0,
                      //     //   ),
                      //     // ),
                      //     const SizedBox(width: 5.0),
                      //     // GestureDetector(
                      //     //   onTap: () {},
                      //     //   child: const Text(
                      //     //     'Remember Me',
                      //     //     style: TextStyle(
                      //     //       color: Colors.black,
                      //     //       fontFamily: 'ProductSans',
                      //     //       fontSize: 12.0,
                      //     //       fontWeight: FontWeight.bold,
                      //     //     ),
                      //     //   ),
                      //     // ),
                      //     // const Spacer(),
                      //     // GestureDetector(
                      //     //   onTap: () {},
                      //     //   child: const Text(
                      //     //     'Forgot Password?',
                      //     //     style: TextStyle(
                      //     //       color: Colors.red,
                      //     //       fontFamily: 'ProductSans',
                      //     //       fontSize: 12.0,
                      //     //     ),
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                      const SizedBox(height: 50),
                      SignUpButton(
                        onPressed: () async {
                          _onButtonPressed();
                        },
                        text: 'Sign In',
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const OfflineCalculator()));
                        },
                        child: const Text(
                          'Calculate Offline',
                          style: TextStyle(color: Colors.black26),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            PositionedButton(
              top: 50,
              right: 20,
              buttonText: 'Register',
              targetPage: SignUpPage(),
            ),
          ],
        ),
      ),
    );
  }
}
