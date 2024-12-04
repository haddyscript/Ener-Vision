import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../YourEnergyCalculator&Compare/compare_two_device.dart';

class AirConditioner extends StatefulWidget {
  const AirConditioner({super.key});

  @override
  State<AirConditioner> createState() => _AirConditionerState();
}

class _AirConditionerState extends State<AirConditioner> {
  String? userId;
  String? applianceId;
  List<dynamic> compareAppliances = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchAppliances();
  }

  Future<void> fetchAppliances() async {
    final url = Uri.parse("http://10.0.2.2:8080/getAllAppliances");

    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        compareAppliances = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load appliances');
    }
  }

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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Air Conditioner',
          showProfile: false,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: content(context, compareAppliances),
      ),
    );
  }

  Widget content(BuildContext context, List<dynamic> compareAppliances) {
    // Accept compareAppliances as a parameter
    return Center(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Text(
              appliancePageExplainer,
              textAlign: TextAlign.center,
              style: TextStyle(),
            ),
          ),
          compareAppliancesContainer(context, compareAppliances),
          // Pass compareAppliances to the container
        ],
      ),
    );
  }

  Widget compareAppliancesContainer(
      BuildContext context, List<dynamic> compareAppliances) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: compareAppliances.asMap().entries.map((entry) {
          int index = entry.key;
          var appliance = entry.value;
          return Stack(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  width: 350,
                  height: 120,
                  decoration: greyBoxDecoration(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${appliance['compareApplianceName'] ?? 'Unknown'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cost per Hour: ₱${appliance['costPerHour'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Monthly Cost: ₱${appliance['monthlyCost'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Carbon Emission: ${appliance['carbonEmission'] ?? 'N/A'} kg CO₂',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                'assets/energy1.png',
                                width: 100,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompareTwoDevices(
                                        userId: userId ?? 'unknown',
                                        compareAppliance:
                                            appliance, // Pass the selected appliance
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
