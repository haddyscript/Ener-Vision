import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/MyEnergyDiary/all_devices_page.dart';
import '../AuthService/base_url.dart';
import '../EnergyManagement/YourEnergy/device_category_page.dart';
import '../StaticPages/energy_efficiency_tab/Electric-Vehicles-Transportation.dart';
import '../StaticPages/energy_efficiency_tab/energy-effieciency-widget.dart';
import '../StaticPages/energy_efficiency_tab/energy-storage-systems.dart';
import '../StaticPages/energy_efficiency_tab/fossil-fuels.dart';
import '../StaticPages/energy_efficiency_tab/renewable-energy.dart';

class YourEnergyTab extends StatefulWidget {
  const YourEnergyTab({super.key});

  @override
  State<YourEnergyTab> createState() => _YourEnergyTabState();
}

class _YourEnergyTabState extends State<YourEnergyTab> {
  String? userId;

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final url = Uri.parse("${ApiConfig.baseUrl}/getUserProfile?userId=$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        content(context),
      ],
    );
  }
}

Widget content(BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        children: <Widget>[
          yourEnergyContent(context),
          optimizeEnergyUsage(context),
        ],
      ),
    ),
  );
}

Widget yourEnergyContent(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 20.0, top: 20.0),
        child: Text(
          'Welcome to EnerVision!',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Want to learn more about energy categories and energy-efficient appliances? Check out the contents below!',
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
      ),
      const SizedBox(height: 10),
      CategorySelectionPage(),
      const SizedBox(
        height: 15.0,
      ),
      energyCategories(context),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Divider(height: 40, color: Colors.grey),
      ),
    ],
  );
}

Widget title(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    textAlign: TextAlign.center,
  );
}

Widget energyCategories(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: title('Energy Categories'),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: Wrap(
            spacing: 15.0,
            runSpacing: 15.0,
            alignment: WrapAlignment.center,
            children: [
              storyTag(
                'Renewable Energy',
                context,
                const RenewableEnergy(selectedIndex: 1),
                'assets/renewable.jpg',
              ),
              storyTag(
                'Fossil Fuels',
                context,
                const FossilFuelsWidget(),
                'assets/fossil.jpg',
              ),
              storyTag(
                'Energy Storage',
                context,
                const EnergyStorage(selectedIndex: 1),
                'assets/energy_storage.webp',
              ),
              storyTag(
                'Energy Efficiency',
                context,
                const EnergyEfficiencyWidget(selectedIndex: 1),
                'assets/efficiency.jpg',
              ),
              storyTag(
                'Electric Vehicles',
                context,
                const ElectricVehicles(selectedIndex: 1),
                'assets/electric.avif',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget storyTag(
    String title, BuildContext context, Widget page, String imagePath) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Container(
      width: 110,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

Widget optimizeEnergyUsage(BuildContext context) {
  return Container(
    decoration: greyBoxDecoration(),
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.all( 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: title('Optimize Energy Usage'),
        ),
        const Text(
          'Identify and track appliances to reduce energy consumption effectively.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AllDevicesPage(
                        userId: '',
                      )),
            );
          },
          child: const Text('Track now'),
        )
      ],
    ),
  );
}
