import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/welcome_page.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';

import '../EnergyManagement/Community/energy_effieciency_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isUserLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    setState(() {
      isUserLoaded = userId != null;
    });

    await Future.delayed(const Duration(seconds: 3));

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => isUserLoaded
          ? const EnergyEfficiencyPage(
              selectedIndex: 0,
            )
          : const LoginPage(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: const Alignment(-5, 0),
                          end: const Alignment(5, 0),
                          colors: [
                            Colors.black.withOpacity(0.0),
                            const Color(0xFF00A991)
                                .withOpacity(0.5), // shadow color
                            Colors.black.withOpacity(0.0),
                          ],
                          stops: [
                            _controller.value - 0.3,
                            _controller.value,
                            _controller.value + 0.3,
                          ],
                        ).createShader(rect);
                      },
                      child: Image.asset(
                        'assets/loading.png',
                        width: 150,
                        color: Colors.white,
                        colorBlendMode: BlendMode.dstIn,
                      ),
                    );
                  },
                ),
              ],
            ),
            ConstrainedBox(
                constraints:
                    const BoxConstraints.expand(height: 200, width: 200),
                child: const LoadingWidget(
                  message: 'Wait For a Second...',
                  color: AppColors.primaryColor,
                ))
          ],
        ),
      ),
    );
  }
}
