import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:supabase_project/StaticPages/aircon.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompareDevice extends StatefulWidget {
  const CompareDevice({super.key});

  @override
  State<CompareDevice> createState() => _CompareDeviceState();
}

class _CompareDeviceState extends State<CompareDevice> {
  String? userId;
  String? applianceId;

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      applianceId = prefs.getString('applianceId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Compare Device',
          showProfile: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
        body: SafeArea(child: content(context)),
      ),
    );
  }

  Widget content(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          topSection(context),
          compareDeviceWidget(context, 'Aircon', 'assets/dialogImage.png'),
          compareDeviceWidget(context, 'Television', 'assets/dialogImage.png'),
          compareDeviceWidget(context, 'Speakers', 'assets/dialogImage.png'),
        ],
      ),
    );
  }
}

Widget topSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search Appliances',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    ),
  );
}

Widget compareDeviceWidget(BuildContext context, String name, String image) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AirConditioner(),
        ),
      );
    },
    child: Container(
      height: 150,
      decoration: greyBoxDecoration(),
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            // Fixed-size image
            Container(
              child: Image.asset(image),
            ),
          ],
        ),
      ),
    ),
  );
}
