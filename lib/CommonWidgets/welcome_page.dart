import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';

import '../EnergyManagement/Community/energy_effieciency_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  String username = '[Username]';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('name');

    setState(() {
      username = storedUsername ?? '[Username]';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/loading.png',
                    width: 150,
                  ),
                  Image.asset(
                    'assets/loading.png',
                    width: 150,
                    color: Colors.white,
                    colorBlendMode: BlendMode.dstIn,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to EnerVision $username',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              // Circular progress indicator
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EnergyEfficiencyPage(selectedIndex: 0)));
                  },
                  child: const Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }
}
