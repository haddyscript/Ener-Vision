import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/Buttons/energy_efficiency_buttons.dart';
import '../../../CommonWidgets/appbar-widget.dart';
import '../../../CommonWidgets/bottom-navigation-bar.dart';
import '../../../ConstantTexts/Theme.dart';
import 'this_month_page.dart';
import 'today.dart';
import 'last_month_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyEnergyDiary extends StatefulWidget {
  const MyEnergyDiary({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  _MyEnergyDiaryState createState() => _MyEnergyDiaryState();
}

class _MyEnergyDiaryState extends State<MyEnergyDiary> {
  int _currentIndex = 0;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex >= 1 && widget.selectedIndex <= 2
        ? widget.selectedIndex
        : 1;
  }

  void _onSegmentTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = const LastMonthPage();
        break;
      case 1:
        currentPage = const TodayPage();
        break;
      case 2:
        currentPage = ThisMonthPage();
        break;
      default:
        currentPage = const TodayPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'My Energy Diary',
          showBackArrow: false,
          showProfile: false,
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                EnergyDiaryButtons(
                  selectedIndex: _currentIndex,
                  onSegmentTapped: _onSegmentTapped,
                ),
                const SizedBox(height: 20),
                currentPage,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
