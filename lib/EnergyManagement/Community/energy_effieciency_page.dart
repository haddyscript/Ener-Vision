import 'package:flutter/material.dart';
import 'package:supabase_project/Buttons/energy_efficiency_buttons.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import '../../../CommonWidgets/appbar-widget.dart';
import '../../../CommonWidgets/bottom-navigation-bar.dart';
import '../../../ConstantTexts/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../YourEnergy/your_energy_tab.dart';
import 'community_tab.dart';

class EnergyEfficiencyPage extends StatefulWidget {
  const EnergyEfficiencyPage({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  @override
  _EnergyEfficiencyPageState createState() => _EnergyEfficiencyPageState();
}

class _EnergyEfficiencyPageState extends State<EnergyEfficiencyPage> {
  int _currentIndex = 0;
  String userId = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex >= 0 && widget.selectedIndex <= 2
        ? widget.selectedIndex
        : 0;
    _printUserIdFromPrefs();
  }

  void _onSegmentTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _printUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');
    print("Current User ID from SharedPreferences: $userId");
    print("Current User ID from SharedPreferences: $username");
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = YourEnergyPageTab();
        break;
      case 1:
        currentPage = const CommunityTab();
        break;
      default:
        currentPage = YourEnergyPageTab();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          showBackArrow: false,
          showTitle: false,
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const Text(
                  'Energy Management',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),
                YourEnergyButtons(
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
