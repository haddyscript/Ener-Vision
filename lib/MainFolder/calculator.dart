import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/MyEnergyDiary/all_devices_page.dart';

import '../../Buttons/sign_up_button.dart';

class EnergyUsageTracker extends StatefulWidget {
  const EnergyUsageTracker({super.key});

  @override
  State<EnergyUsageTracker> createState() => _EnergyTrackerState();
}

class _EnergyTrackerState extends State<EnergyUsageTracker> {
  final TextEditingController applianceNameController = TextEditingController();
  String? selectedApplianceType;
  late String userId = '';
  int wattage = 0;
  int hours = 0;
  // List<bool> isSelectedDays = [false, false, false, false, false, false, false];
  List<bool> isSelectedDays = List.filled(7, false);
  void _sendApplianceData(List<int> selectedDays) {
    // Here you can prepare your request to the backend
    // Use the selectedDays variable when constructing the request body
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
        body: SafeArea(child: content()),
      ),
    );
  }

  void getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch daily consumption.");
      return;
    }
  }

  void _signUp() {
    if (applianceNameController.text.trim().isEmpty) {
      showCustomDialog(
        context: context,
        title: 'Invalid Input',
        message: 'Please fill in all fields without just whitespace.',
        buttonText: 'Okay, Got it!',
      );
      return;
    }
    if (wattage <= 0 || hours <= 0) {
      showCustomDialog(
        context: context,
        title: 'Invalid Input',
        message:
            'Oops! The input field for is empty. Please try again by adding a valid input.',
        buttonText: 'Okay, Got it!',
      );
      return;
    }

    if (selectedApplianceType == null) {
      showCustomDialog(
        context: context,
        title: 'Invalid Input',
        message: 'Oops! The input field for Appliance Type is empty.',
        buttonText: 'Okay, Got it!',
      );
      return;
    }

    if (!isSelectedDays.any((selected) => selected)) {
      showCustomDialog(
        context: context,
        title: 'Invalid Selection',
        message: 'Please select at least one day of the week.',
        buttonText: 'Okay, Got it!',
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AllDevicesPage(userId: userId)),
    );
  }

  Widget content() {
    return Column(
      children: [
        topSection(context),
        bottomSection(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                selectAppliance(),
                usageFrequency(),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget topSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30.0),
      decoration: const BoxDecoration(color: AppColors.primaryColor),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.only(left: 30.0),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 60.0),
              const Text(
                "Energy Tracker",
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Text(
              energyTrackerExplainer,
              style: TextStyle(color: Colors.white, letterSpacing: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSection() {
    return Container(
      color: AppColors.primaryColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                controller: applianceNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Appliance Name',
                  hintStyle:
                      TextStyle(color: Color(0xFFB1B1B1), fontSize: 14.0),
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color(0xFFB1B1B1),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget selectAppliance() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, bottom: 10.0),
            child: Text(
              'Appliance Details',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Select Appliance Type'),
          ),
          SizedBox(height: 20.0),
          Center(
            child: Wrap(
              spacing: 20.0,
              runSpacing: 20.0,
              alignment: WrapAlignment.center,
              children: [
                applianceType('Kitchen Appliances'),
                applianceType('Laundry Appliances'),
                applianceType('Cleaning Appliances'),
                applianceType('Climate Control Appliances'),
                applianceType('Personal Care Appliances'),
                applianceType('Home Entertainment Appliances'),
                applianceType('Home Office Appliances'),
                applianceType('Small Appliances'),
                applianceType('Miscellaneous Appliances'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget usageFrequency() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0, left: 20.0),
                child: Text(
                  'Usage Pattern',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    wattageValue(),
                    const SizedBox(height: 30),
                    hoursPerDay(),
                    const SizedBox(height: 10.0),
                    daysUsedPerWeek(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget wattageValue() {
    final TextEditingController _controller = TextEditingController();

    void incrementWattage(StateSetter setState) {
      setState(() {
        if (wattage < 10000) {
          wattage++;
          _controller.text = wattage.toString();
        }
      });
    }

    void decrementWattage(StateSetter setState) {
      setState(() {
        if (wattage > 0) {
          wattage--;
          _controller.text = wattage.toString();
        }
      });
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Wattage',
              style: TextStyle(fontSize: 14.0),
            ),
            Container(
              decoration: greyBoxDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove,
                          size: 10.0, color: Colors.black),
                      onPressed: () {
                        decrementWattage(setState);
                      },
                    ),
                  ),
                  Container(
                    width: 50.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            final parsedValue = int.tryParse(value);
                            if (parsedValue != null &&
                                parsedValue >= 0 &&
                                parsedValue <= 10000) {
                              wattage = parsedValue;
                            } else {
                              _controller.text = wattage.toString();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add,
                          size: 10.0, color: Colors.black),
                      onPressed: () {
                        incrementWattage(setState);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget hoursPerDay() {
    final TextEditingController _controller = TextEditingController();

    void incrementhoursPerDay(StateSetter setState) {
      setState(() {
        if (hours < 24) {
          hours++;
          _controller.text = hours.toString();
        }
      });
    }

    void decrementhoursPerDay(StateSetter setState) {
      setState(() {
        if (hours > 0) {
          hours--;
          _controller.text = hours.toString();
        }
      });
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hours used Per Day',
              style: TextStyle(fontSize: 14.0),
            ),
            Container(
              decoration: greyBoxDecoration(),
              child: Row(
                children: [
                  // Decrement Button
                  Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 10.0,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        decrementhoursPerDay(setState);
                      },
                    ),
                  ),
                  Container(
                    width: 50.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            final parsedValue = int.tryParse(value);
                            if (parsedValue != null &&
                                parsedValue >= 0 &&
                                parsedValue <= 24) {
                              hours = parsedValue;
                            } else {
                              _controller.text = hours.toString();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 10.0,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        incrementhoursPerDay(setState);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget daysUsedPerWeek() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'Days used Per Week',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildDayButton('M', 0, setState),
                    buildDayButton('T', 1, setState),
                    buildDayButton('W', 2, setState),
                    buildDayButton('Th', 3, setState),
                    buildDayButton('F', 4, setState),
                    buildDayButton('St', 5, setState),
                    buildDayButton('S', 6, setState),
                  ],
                ),
              ),
              const SizedBox(height: 50.0),
              SignUpButton(
                onPressed: () {
                  List<int> selectedDays = [];
                  for (int i = 0; i < isSelectedDays.length; i++) {
                    if (isSelectedDays[i]) {
                      selectedDays
                          .add(i); // Add the index (day number) if selected
                    }
                  }
                  _sendApplianceData(
                      selectedDays); // Send selected days to backend
                },
                text: 'View Statistics',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDayButton(String day, int index, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelectedDays[index] = !isSelectedDays[index];
        });
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor:
            isSelectedDays[index] ? const Color(0xFF1BBC9B) : Colors.grey[200],
        child: Text(
          day,
          style: TextStyle(
            fontSize: 14.0,
            color: isSelectedDays[index] ? Colors.white : Colors.black,
            fontWeight:
                isSelectedDays[index] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget applianceType(String title) {
    bool isSelected = selectedApplianceType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedApplianceType = title;
        });
      },
      child: Container(
        width: 100.0,
        height: 50.0,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1BBC9B) : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.black26 : Colors.grey.withOpacity(0.5),
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonText,
  IconData? icon = Icons.error_outline,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
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
              Icon(
                icon ?? Icons.error_outline,
                color: AppColors.secondaryColor,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
