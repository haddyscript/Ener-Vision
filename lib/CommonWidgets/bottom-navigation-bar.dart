import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyPage/offline_calculator_v2.dart';
import 'package:supabase_project/MyEnergyDiary/all_devices_page.dart';
import 'package:supabase_project/MyEnergyDiary/segmentPages/my_energy_diary_page.dart';
import 'package:supabase_project/PreCode/Provider/ApplianceWidget.dart';
import 'package:supabase_project/PreCode/accountpagewithprofile.dart';
import 'package:supabase_project/Settings/app-settings-widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../EnergyManagement/Community/energy_effieciency_page.dart';
import '../MyEnergyDiary/carousel.dart';

class BottomNavigation extends StatefulWidget {
  final int selectedIndex;
  const BottomNavigation({Key? key, required this.selectedIndex});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = -1;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load the userId when the widget initializes
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  void _handleTap(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnergyEfficiencyPage(selectedIndex: 0),
            // builder: (context) => const YourEnergyPage(),
          ),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyEnergyDiary(
              selectedIndex: 1,
            ),
          ),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllDevicesPage(userId: userId!),
          ),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OfflineCalculatorV2(),
            // builder: (context) => EnergyPowerUsed(
            //   value: 'we',
            //   title: '23',
            // ),
          ),
        );
      } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppSettings(),
          ),
        );
      }
    });
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  GoalsPage()),
      );

    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AppSettings(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return customBottomNavigationBar1(onTap: _handleTap);
  }

  BottomNavigationBar customBottomNavigationBar1(
      {required Function(int) onTap}) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      currentIndex: widget.selectedIndex,
      onTap: onTap,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.commute),
          label: 'Energy',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.crisis_alert_outlined),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
