import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/appliance_information_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/new_add_appliance_dialog.dart';

import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/dialogs/edit_appliance_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../AuthService/base_url.dart';
import '../AuthService/kwh_rate.dart';
import '../AuthService/preferences.dart';
import '../CommonWidgets/controllers/app_controllers.dart';

class AppliancesContainer extends StatefulWidget {
  const AppliancesContainer({super.key});

  @override
  _AppliancesContainerState createState() => _AppliancesContainerState();
}

class _AppliancesContainerState extends State<AppliancesContainer> {
  final AppControllers controllers = AppControllers();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final formatter = NumberFormat('#,##0.00', 'en_PHP');
  final Map<String, String> _electricProviders = {
    'Cebu Electric Cooperative': '10.5',
    'Visayan Electric Company (VECO) - Residential': '11.2',
    'Visayan Electric Company (VECO) - Commercial': '15.2',
    'Mactan Electric Company - Residential': '10.8',
    'Mactan Electric Company - Commercial': '13.8',
    'Churba': '12.0',
    'Gengeng': '15.5',
    'Juju on the Beat': '18',
    'Eyy': '33',
    'Waw': '21',
  };

  List<Map<String, dynamic>> appliances = [];
  List<int> selectedDays = [];
  Map<String, dynamic> dailyCost = {};

  bool isLoading = true;

  late String index = '0';
  String? kwhRate;
  String? _selectedProvider;

  double totalDailyConsumptionCost = 0.0;
  double totalDailyKwhConsumption = 0.0;
  double totalDailyCO2Emissions = 0.0;

  @override
  void initState() {
    super.initState();
    fetchTodayAppliances();
    fetchDailyCost();
    getKwhRate();
  }

  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        myAppliancesContent(),
      ],
    );
  }

  Future<void> fetchTodayAppliances() async {
    setState(() {
      isLoading = true; // Set loading state to true before the fetch
    });

    try {
      final todayData = await ApplianceService.fetchTodayAppliance();

      setState(() {
        appliances = todayData['appliances'];
        totalDailyConsumptionCost = todayData['totalDailyConsumptionCost'];
        totalDailyKwhConsumption = todayData['totalDailyKwhConsumption'];
        totalDailyCO2Emissions = todayData['totalDailyCO2Emissions'];
        isLoading =
            false; // Set loading state to false after the data is fetched
      });
    } catch (e) {
      setState(() {
        isLoading =
            false; // Set loading state to false even if there is an error
      });
    }
  }

  Widget myAppliancesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TotalCostDisplay(
              cost: totalDailyConsumptionCost != null
                  ? '₱ ${totalDailyConsumptionCost.toStringAsFixed(2)}'
                  : 'Cost',
            ),
            const SizedBox(width: 20),
            TotalCostDisplay(
              cost: totalDailyKwhConsumption != null
                  ? '${totalDailyKwhConsumption.toStringAsFixed(2)} KWH'
                  : 'KWH',
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            top: 30,
          ),
          child: Text('Appliance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const Center(
              child: LoadingWidget(
            message: 'Fetching Today\'s Appliances...',
            color: AppColors.primaryColor,
          ))
        else if (appliances.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 200, bottom: 100),
            child: const Center(
              child: Text(
                'No appliances added for \n Today\'s Appliances...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ...appliances.asMap().entries.map((entry) {
            int index = entry.key;
            var appliance = entry.value;

            return Center(
              child: GestureDetector(
                onTap: () {
                  showApplianceInformationDialog(index);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: greyBoxDecoration(),
                  child: ListTile(
                    leading: ClipOval(
                      child: Image.asset(
                        appliance['imagePath'] ?? 'assets/appliance.jpg',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      appliance['applianceName'] ?? 'Unknown Device',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Wattage: ${appliance['wattage'] ?? 'N/A'}'
                        '     '
                        'Hours Used: ${appliance['usagePatternPerDay'] ?? 'N/A'}\n'),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showActionSheet(context, index),
                      child: Image.asset(
                        'assets/edit.png',
                        scale: 0.7,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                final kwhRate = await getKwhRate();

                if (kwhRate != null) {
                  _showAddApplianceDialog(
                    context,
                  );
                } else {
                  _showKwhRateDialog(
                    context,
                    controllers.kwhRateController,
                    saveKwhRate,
                    fetchTodayAppliances,
                    fetchDailyCost,
                  );
                }
              },
              icon: const Icon(Icons.add, size: 0),
              label: const Text('Add Appliance'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _popupTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _popupDescription(String description) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[500],
        fontFamily: 'Montserrat',
      ),
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

  Future<void> deleteAppliance(String applianceId) async {
    try {
      await ApplianceService.deleteAppliance(applianceId);
      print('Appliance deleted successfully');
    } catch (e) {
      print('Error deleting appliance: $e');
    }
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Appliance not Added',
      message:
          'Appliance name must not have a duplicate.\nPlease use a different name.',
      buttonText: 'OK',
    );
  }

  Future<Object?> _showKwhRateDialog(
    BuildContext context,
    TextEditingController kwhRateController,
    Function saveKwhRate,
    Function fetchAppliances,
    Function fetchDailyCost,
  ) async {
    {
      return showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: '',
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: const Duration(milliseconds: 200),
          transitionBuilder: (context, animation1, animation2, child) {
            return Transform.scale(
              scale: animation1.value,
              child: Opacity(
                opacity: animation1.value,
                child: child,
              ),
            );
          },
          pageBuilder: (context, animation1, animation2) {
            return AlertDialog(
              title: const Text('Enter kWh Rate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      value: _selectedProvider,
                      isExpanded: true,
                      hint: const Text('Select your Electric Service Provider'),
                      items: _electricProviders.keys.map((String provider) {
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
                          _selectedProvider = newValue;
                          controllers.kwhRateController.text =
                              _electricProviders[newValue!]!;
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
                    ),
                  ),
                  const SizedBox(height: 15),
                  Flexible(
                    child: TextField(
                      controller: controllers.kwhRateController,
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
                          String kwhRate = controllers.kwhRateController.text;

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
          });
    }
  }

  Future<void> addAppliance() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/addApplianceNewLogic");
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

    // Retrieve userId from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found in shared preferences');
      return;
    }

    // Get the token from SharedPreferences or other method
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
        fetchTodayAppliances();
        fetchDailyCost();
      } else {
        await _showApplianceErrorDialog(context);
      }
    } else {
      print('No token found');
    }
  }

  Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updates) async {
    try {
      if (updates.containsKey('applianceName')) {
        updates['applianceName'] = toTitleCase(updates['applianceName']);
      }
      await ApplianceService.updateAppliance(applianceId, updates);
      showSnackBar(context, 'Update Success');
    } catch (e) {
      showSnackBar(context, 'Appliance can only be updated once a month.');
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
          },
        );
      },
    );
  }

  void _showActionSheet(BuildContext context, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Appliance Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              openEditApplianceDialog(index);
            },
            child: const Text('Edit Appliance'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAppliance(index);
            },
            child: const Text('Delete Appliance'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
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
          'Fetched oldtotalDailyKwhConsumption: ${dailyCost?['totalDailyKwhConsumption']}');
    } else {
      print('Failed to fetch daily cost');
    }
  }

  void openEditApplianceDialog(int index) {
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
        return EditApplianceDialog(
          editApplianceNameController: controllers.editApplianceNameController,
          editWattageController: controllers.editWattageController,
          editUsagePatternController: controllers.editUsagePatternController,
          editWeeklyPatternController: controllers.editWeeklyPatternController,
          formKey: formKey,
          editAppliance: () {},
          appliance: appliance,
          updateAppliance: updateAppliance,
          fetchAppliances: fetchTodayAppliances,
          fetchDailyCosts: fetchDailyCost,
        );
      },
    );
  }

  void _confirmDeleteAppliance(int index) {
    final appliance = appliances[index];

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
                _popupTitle('Delete Appliance?'),
                const SizedBox(height: 10),
                _popupDescription(
                  'Are you sure you want to delete this appliance? This cannot be undone.',
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
                      onPressed: () {
                        deleteAppliance(appliance['_id']).then((_) {
                          fetchTodayAppliances();
                          fetchDailyCost();
                          Navigator.of(context).pop();
                        });
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
                        'Delete',
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

  void saveKwhRate(String kwhRate) async {
    try {
      await KWHRateService.saveKwhRate(kwhRate);
      print('kWh Rate saved successfully');
    } catch (e) {
      print('Failed to save kWh Rate: $e');
    }
  }
}
