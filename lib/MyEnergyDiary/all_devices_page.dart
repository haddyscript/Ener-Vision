import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/appliance_information_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/micaella.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/dialogs/new_add_appliance_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import '../../ConstantTexts/Theme.dart';
import '../../YourEnergyCalculator&Compare/compare_device.dart';
import '../AuthService/kwh_rate.dart';
import '../AuthService/preferences.dart';
class AllDevicesPage extends StatefulWidget {
  final String userId;
  const AllDevicesPage({super.key, required this.userId});
  @override
  _AllDevicesPageState createState() => _AllDevicesPageState();
}
class _AllDevicesPageState extends State<AllDevicesPage> {
  final AppControllers controllers = AppControllers();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
// Remove the [] list of Energy Providers
  late final TextEditingController controller;
  Map<String, dynamic> dailyCost = {};
  List<dynamic> appliances = [];
  List<int> selectedDays = [];
  bool isLoading = false;
  late String? userId;
  late String? selectedDeviceId;
  String? _selectedProvider;
  @override
  void dispose() {
    controllers.addUsagePatternController.dispose();
    controllers.addApplianceCategoryController.dispose();
    controllers.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    fetchAppliances();
    fetchDailyCost();
    getKwhRate();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
        appBar: customAppBar1(
          title: 'All Devices',
          showBackArrow: true,
          showProfile: true,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            myAppliancesContent(),
            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: ElevatedButton(
                onPressed: () async {
                  final kwhRate = await getKwhRate();
                  if (kwhRate != null) {
                    _showAddApplianceDialog(
                      context,
                    );
                  } else {
                    showKwhRateDialog(context, controllers.kwhRateController,
                        saveKwhRate, fetchAppliances, fetchDailyCost);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget myAppliancesContent() {
    if (isLoading) {
      return const Center(
          child: LoadingWidget(
            message: 'Fetching all appliances',
            color: AppColors.primaryColor,
          ));
    } else if (appliances.isEmpty) {
      return Center(
        child: Text(
          'No appliance added.\nTap "+" to start tracking.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            appliancesContent(),
          ],
        ),
      );
    }
  }
  Widget appliancesContent() {
    return Expanded(
      child: ListView(
        children: appliances.asMap().entries.map((entry) {
          var appliance = entry.value;
          int index = entry.key;

          return GestureDetector(
            onTap: () {
              showApplianceInformationDialog(index);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
                  decoration: greyBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 130),
                        child: Text(
                          '${appliance['applianceName'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.battery_charging_full),
                              const SizedBox(width: 5),
                              Text('${appliance['wattage'] ?? 'N/A'} W'),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.watch_later_outlined),
                              const SizedBox(width: 5),
                              Text(
                                  '${appliance['usagePatternPerDay'] ?? 'N/A'} hours'),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined),
                              const SizedBox(width: 5),
                              Text(
                                appliance['createdAt'] != null
                                    ? DateFormat('MM/dd').format(
                                    DateTime.parse(appliance['createdAt']))
                                    : 'null',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
                // Appliance Image (overlapping the container)
                deviceImages(appliance),
                // Compare Button (overlapping at the bottom-right)
                // Positioned(
                //   bottom: -10,
                //   right: 30,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const CompareDevice(),
                //         ),
                //       );
                //     },
                //     style: ElevatedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 30, vertical: 10),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //     child: const Text('Compare'),
                //   ),
                // ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget deviceImages(appliance) {
    return Positioned(
      top: -5,
      left: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          appliance['imagePath'] ?? 'assets/appliance.jpg',
          width: 102,
          height: 86,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget dailyConsumption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TotalCostDisplay(
          cost: dailyCost['totalDailyConsumptionCost'] != null
              ? '₱ ${double.parse(dailyCost['totalDailyConsumptionCost'].toString()).toStringAsFixed(2)}'
              : 'N/A',
        ),
        const SizedBox(width: 20),
        TotalCostDisplay(
          cost: dailyCost['totalDailyKwhConsumption'] != null
              ? '${double.parse(dailyCost['totalDailyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
              : 'N/A',
        ),
      ],
    );
  }
  Future<double?> getKwhRate() async {
    try {
      double? kwhRate = await KWHRateService.getKwhRate();
      if (kwhRate != null) {
        print('Current kWh Rate: $kwhRate');
        return kwhRate;
      } else {
        print('kWh Rate not found');
        return null;
      }
    } catch (e) {
      print('Error fetching kWh rate: $e');
      return 0.00; // Return null in case of error
    }
  }
  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    ErrorDialogButton errorDialog = const ErrorDialogButton(
      title: 'Appliance not Added',
      message:
      'Invalid Appliance\nOops! The appliance either already exists in your list or the name contains only spaces. Please add a different appliance with a valid name.',
    );
    errorDialog.showErrorDialog(context);
  }
  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      print("User ID is null. Cannot fetch appliances.");
      setState(() {
        isLoading = false;
      });
      return;
    }
    final url = Uri.parse(
        "http://10.0.2.2:8080/getAllUsersAppliances/$userId/appliances");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      setState(() {
        appliances = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        isLoading = false;
      });
    } else {
      print('Failed to fetch appliances: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }
  void showApplianceInformationDialog(int index) {
    var appliance = appliances[index];

    controllers.editApplianceNameController.text =
        appliance['applianceName'] ?? '';
    controllers.editWattageController.text =
        appliance['wattage']?.toString() ?? '';
    controllers.editUsagePatternController.text =
        appliance['usagePatternPerDay']?.toString() ?? '';
    controllers.editWeeklyPatternController.text =
        appliance['selectedDays']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ApplianceInformationDialog(
          appliance: appliance,
        );
      },
    );
  }

  Future<void> addAppliance() async {
    final url = Uri.parse("http://10.0.2.2:8080/addApplianceNewLogic");
    String applianceName = toTitleCase(
      controllers.addApplianceNameController.text.trim(),
    );
    final Map<String, dynamic> applianceData = {
      'applianceName': applianceName,
      'wattage': int.tryParse(controllers.addWattageController.text) ?? 0,
      'usagePatternPerDay':
      double.tryParse(controllers.addUsagePatternController.text) ?? 0.0,
      'applianceCategory':
      controllers.addApplianceCategoryController.text.trim(),
      'selectedDays': selectedDays,
    };
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    if (userId == null) {
      print('User ID not found in shared preferences');
      return;
    }
    String? token = await getToken();
    if (token != null) {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'applianceData': applianceData,
        }),
      );
      if (response.statusCode == 201) {
        fetchAppliances();
      } else {
        await _showApplianceErrorDialog(context);
      }
    }
  }
// Remove the _showKwhRateDialog() part, and insert this one
  Future<void> showKwhRateDialog(
      BuildContext context,
      TextEditingController kwhRateController,
      Function saveKwhRate,
      Function fetchAppliances,
      Function fetchDailyCost,
      ) async {
    String? selectedProvider;
    Map<String, String> providers = {};
    Future<void> fetchProviders() async {
      try {
        final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/api/providers'));
        if (response.statusCode == 200) {
          final List<dynamic> providerList = json.decode(response.body);
          print('Energy providers fetched from MongoDB:');
          providerList.forEach((provider) {
            print(
                'Provider: ${provider['providerName']}, Rate: ${provider['ratePerKwh']}');
          });
          providers = {
            for (var provider in providerList)
              provider['providerName']: provider['ratePerKwh'].toString()
          };
        } else {
          throw Exception('Failed to load providers');
        }
      } catch (e) {
        print('Error fetching providers: $e');
      }
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Icon and Title
                  const Icon(
                    Icons.electrical_services,
                    size: 50,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kilowatt-Hour Rate',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Fetch providers and display them
                  FutureBuilder<void>(
                    future: fetchProviders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error loading providers');
                      } else {
                        return DropdownButtonFormField<String>(
                          value: selectedProvider,
                          isExpanded: true,
                          hint: const Text(
                              'Select your Electric Service Provider'),
                          items: providers.keys.map((String provider) {
                            return DropdownMenuItem<String>(
                              value: provider,
                              child: Text(
                                provider,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProvider = newValue;
                              kwhRateController.text = providers[newValue!]!;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  // Input for Kilowatt Hour Rate (kWh)
                  TextField(
                    controller: kwhRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Kilowatt Hour Rate (kWh)',
                      hintStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                                color: Color(0xFFB1B1B1), width: 1),
                          ),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 14.0)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String kwhRate = kwhRateController.text;
                          try {
                            await saveKwhRate(kwhRate);
                            Navigator.of(context).pop();
                            _showAddApplianceDialog(context);
                            fetchAppliances();
                            fetchDailyCost();
                          } catch (e) {
                            print('Failed to save kWh rate: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xFF1BBC9B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 14.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Future<void> saveKwhRate(String kwhRate) async {
    try {
      await KWHRateService.saveKwhRate(kwhRate);
      print('kWh rate saved successfully');
    } catch (e) {
      print('Error saving kWh rate: $e');
    }
  }
  void fetchDailyCost() async {
    ApplianceService applianceService = ApplianceService();
    final result = await applianceService.getDaily();
    if (result != null) {
      setState(() {
        dailyCost = result;
      });
      print(
          'Fetched totalDailyConsumptionCost: ${dailyCost?['totalDailyConsumptionCost']}');
      print(
          'Fetched totalDailyKwhConsumption: ${dailyCost?['totalDailyKwhConsumption']}');
    } else {
      print('Failed to fetch daily cost');
    }
  }
  void _showAddApplianceDialog(BuildContext context) {
    controllers.addApplianceNameController.clear();
    controllers.addWattageController.clear();
    controllers.addUsagePatternController.clear();
    controllers.addApplianceCategoryController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AddApplianceDialog(
          addApplianceNameController: controllers.addApplianceNameController,
          addWattageController: controllers.addWattageController,
          addUsagePatternController: controllers.addUsagePatternController,
          addApplianceCategoryController:
          controllers.addApplianceCategoryController,
          formKey: formKey,
          addAppliance: (List<int> selectedDays) {
            setState(() {
              this.selectedDays = selectedDays;
            });
            addAppliance();
            fetchDailyCost();
          },
        );
      },
    );
  }
}
