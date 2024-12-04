import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';

import '../CommonWidgets/bottom-navigation-bar.dart';

class CustomPieChart extends StatefulWidget {
  const CustomPieChart({super.key});

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  Map<String, double> dataMap = {};
  bool isLoading = false;
  List<Map<String, dynamic>> appliances = [];
  final List<Color> colorList = [
    Color(0xFFFFC0CB), // Pink
    Color(0xFFFFE4B5), // Moccasin
    Color(0xFF98FB98), // PaleGreen
    Color(0xFFADD8E6), // LightBlue
    Color(0xFFFFE4E1), // MistyRose
    Color(0xFFF0E68C), // Khaki
    Colors.blue,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.lightBlue,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.amber,
    Colors.deepOrange,
    Colors.pink,
    Color(0xFF8B4513), // SaddleBrown
    Color(0xFF2F4F4F), // DarkSlateGray
    Color(0xFF6B8E23), // OliveDrab
    Color(0xFFD2691E), // Chocolate
    Color(0xFF808000), // Olive
    Color(0xFF556B2F), // DarkOliveGreen
    Color(0xFFFF1493), // DeepPink
    Color(0xFFFF6347), // Tomato
    Color(0xFF00FF00), // Lime
    Color(0xFF8A2BE2), // BlueViolet
    Color(0xFFFF4500), // OrangeRed
    Color(0xFF32CD32), // LimeGreen
    Color(0xFFFF00FF), // Magenta
    Color(0xFF00FF00), // Green
    Color(0xFFFFFF00), // Yellow
    Color(0xFFFF6347), // Tomato
    Color(0xFF00FFFF), // Cyan
    Color(0xFFFF1493), // DeepPink

    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.cyan,
    Color(0xFFFF1493), // DeepPink
    Color(0xFFFF6347), // Tomato
    Color(0xFF00FF00), // Lime
    Color(0xFF8A2BE2), // BlueViolet
    Color(0xFFFF4500), // OrangeRed
    Color(0xFF32CD32),
  ];

  /// Fetch appliances from the API and prepare the dataMap for the pie chart
  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appliancesData = await ApplianceService.fetchAppliance();
      setState(() {
        appliances = List<Map<String, dynamic>>.from(appliancesData);

        // Prepare the dataMap for the pie chart
        dataMap = {
          for (var appliance in appliances)
            if (appliance["monthlyCost"] != null &&
                appliance["applianceName"] != null)
              appliance["applianceName"]: (appliance["monthlyCost"] is int
                  ? (appliance["monthlyCost"] as int).toDouble()
                  : appliance["monthlyCost"]) as double
        };

        isLoading = false;
      });
    } catch (e) {
      // Handle errors here
      print("Error fetching appliances: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppliances(); // Fetch data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
        appBar: customAppBar3(
          showBackArrow: true,
          showProfile: false,
          showTitle: false,
          onBackPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator()) // Show loading indicator
              : appliances.isEmpty
                  ? const Center(child: Text("No data available."))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          topSection(),
                          // Only render PieChart if dataMap is not empty
                          dataMap.isNotEmpty
                              ? PieChart(
                                  dataMap: dataMap,
                                  animationDuration:
                                      const Duration(milliseconds: 800),
                                  chartLegendSpacing: 32,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 3.2,
                                  colorList: colorList,
                                  initialAngleInDegree: 0,
                                  chartType: ChartType.ring,
                                  ringStrokeWidth: 32,
                                  centerText: "Appliances",
                                  legendOptions: const LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.right,
                                    showLegends: true,
                                    legendShape: BoxShape.circle,
                                    legendTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    showChartValuesInPercentage: false,
                                    showChartValuesOutside: false,
                                    decimalPlaces: 1,
                                  ),
                                )
                              : const Center(child: Text("No data to display")),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget topSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(color: AppColors.primaryColor),
      child: Column(
        children: const [
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              pageTitleDescription,
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Widget barChart() {
  //   return SizedBox(
  //     height: 300, // Set a fixed height for the BarChart widget
  //     child: BarChart(
  //       BarChartData(
  //         gridData: FlGridData(show: true),
  //         titlesData: FlTitlesData(show: true),
  //         borderData: FlBorderData(show: true),
  //         barGroups: dataMap.entries.map((entry) {
  //           return BarChartGroupData(
  //             x: dataMap.keys
  //                 .toList()
  //                 .indexOf(entry.key), // Use the appliance index for X axis
  //             barRods: [
  //               BarChartRodData(
  //                 toY: entry.value, // Set the value to 'toY' instead of 'y'
  //                 color:
  //                     Colors.blue, // Use 'color' (singular) instead of 'colors'
  //                 width: 15,
  //                 borderRadius: BorderRadius.zero,
  //               ),
  //             ],
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }
}
