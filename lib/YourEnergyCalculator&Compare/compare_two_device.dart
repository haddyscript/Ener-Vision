import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompareTwoDevices extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> compareAppliance;
  const CompareTwoDevices(
      {super.key, required this.userId, required this.compareAppliance});

  @override
  State<CompareTwoDevices> createState() => _CompareTwoDevicesState();
}

class _CompareTwoDevicesState extends State<CompareTwoDevices> {
  List<dynamic> appliances = [];
  String? compareAppliances;

  @override
  void initState() {
    super.initState();
    _loadAppliances();
    _loadCompare();
  }

  Future<void> _loadAppliances() async {
    try {
      await fetchAppliances(); // Fetch appliances
    } catch (e) {
      print('Failed to load appliances: $e');
    }
  }

  Future<void> _loadCompare() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      compareAppliances = prefs.getString('compareId');
    });
  }

  Future<void> fetchAppliances() async {
    final url = Uri.parse(
        "http://10.0.2.2:8080/getAllUsersAppliances/${widget.userId}/appliances");

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty) {
        setState(() {
          appliances = data;
        });
        print("Fetched appliances: $data"); // Log the fetched appliances
      } else {
        print("No appliances found.");
      }
    } else {
      print('Failed to load appliances: ${response.statusCode}');
      throw Exception('Failed to load appliances');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Compare Two Devices',
          showBackArrow: true,
          showProfile: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: content(
            context,
            appliances,
            compareAppliances != null
                ? jsonDecode(compareAppliances!)
                : <String, dynamic>{}), // Pass a Map instead of an Object
      ),
    );
  }
}

Widget content(BuildContext context, List<dynamic> appliances,
    Map<String, dynamic> compareAppliance) {
  return Container(
    decoration: greyBoxDecoration(),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: appliances.isNotEmpty
            ? Column(
                children: [
                  content1(
                    context,
                    appliances[0]['applianceName'] ??
                        'Unknown', // First appliance
                    compareAppliance, // Use the passed compareAppliance
                  ),
                  mainContainer(context, appliances, compareAppliance),
                ],
              )
            : const Text('Loading appliances...'),
      ),
    ),
  );
}

Widget content1(BuildContext context, String appliance1,
    Map<String, dynamic> compareAppliance) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Container(
        height: 70,
        width: 153,
        decoration: greyBoxDecoration(),
        alignment: Alignment.center,
        child: Text(
          appliance1,
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        height: 70,
        width: 153,
        alignment: Alignment.center,
        decoration: greyBoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              compareAppliance['compareApplianceName'] ?? 'Unknown',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget mainContainer(BuildContext context, List<dynamic> appliances,
    Map<String, dynamic> compareAppliance) {
  return Container(
    decoration: greyBoxDecoration(),
    child: Stack(
      children: [
        Column(
          children: [
            _compareTitle('Compare'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                powerWidget(
                  context,
                  "Cost per Hour: ₱${compareAppliance['costPerHour'] ?? 'N/A'}",
                ),
                const SizedBox(width: 10),
                powerWidget(
                  context,
                  (compareAppliance['wattage'] ?? 'N/A').toString(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget powerWidget(
  BuildContext context,
  String appliance1,
) {
  return Center(
    child: Container(
      height: 70,
      width: 153,
      decoration: greyBoxDecoration(),
      alignment: Alignment.center,
      child: Text('Wattage: $appliance1'),
    ),
  );
}

Widget _compareTitle(String title) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    height: 45,
    width: 165,
    decoration: BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white, // Text color
        fontWeight: FontWeight.bold, // Font weight
        fontSize: 16, // Font size
      ),
    ),
  );
}
