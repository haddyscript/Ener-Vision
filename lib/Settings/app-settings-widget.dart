import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/PreCode/accountPage.dart';
import 'package:supabase_project/PreCode/community_guidelines.dart';
import 'package:supabase_project/PreCode/micaella.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import '../ConstantTexts/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          showBackArrow: true,
          onBackPressed: () {
            Navigator.pop(context);
          },
          showTitle: false,
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 4),
        body: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: ListView(
            children: [
              const SizedBox(height: 50),
              settingsOptions(
                context,
                'Account',
                Icons.person,
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
                showDivider: false,
              ),
              const SizedBox(height: 50),
              ...[
                settingsOptions(
                  context,
                  'Notification Settings',
                  Icons.notifications,
                  () {},
                ),
                settingsOptions(
                  context,
                  'Daily Energy Goals',
                  Icons.security,
                  () {
                    // Navigate to Privacy page
                  },
                ),
                settingsOptions(
                  context,
                  'Energy Insights',
                  Icons.energy_savings_leaf_outlined,
                  () {
                    // Navigate to Energy Insights page
                  },
                ),
                settingsOptions(
                  context,
                  'App Language',
                  Icons.brush,
                  () {
                    // Navigate to App Appearance page
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
              ].expand((widget) => [widget, const SizedBox(height: 0)]),
              const SizedBox(height: 50),
              settingsOptions(
                context,
                'Support and FAQs',
                Icons.support_agent,
                () {
                  // Navigate to Support page
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FAQsPage()));
                },
              ),
              settingsOptions(
                context,
                'Community Guidelines',
                Icons.support_agent,
                () {
                  // Navigate to Support page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityGuidelines()));
                },
              ),
              settingsOptions(
                context,
                'Sign out',
                Icons.logout,
                () => _confirmLogout(),
                showDivider: true,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingsOptions(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {bool showDivider = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                children: [
                  Icon(icon, size: 30),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning,
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Logout?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
