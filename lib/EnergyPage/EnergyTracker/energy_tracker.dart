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

class EnergyTracker extends StatefulWidget {
  const EnergyTracker({super.key});

  @override
  State<EnergyTracker> createState() => _EnergyTrackerState();
}

class _EnergyTrackerState extends State<EnergyTracker> {
  String? selectedApplianceType;
  late String userId = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
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

  void _signUp() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AllDevicesPage(userId: userId)),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          topSection(),
          bottomSection(),
          selectAppliance(),
          usageFrequency(),
          monthlyUsage(),
          monthlyUsageNotes(),
          const SizedBox(height: 100)
        ],
      ),
    );
  }

  Widget topSection() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primaryColor),
      child: const Column(
        children: [
          Text(
            "Energy Tracker",
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // CostKilowatt(costKilo, cost),
                // CostKilowatt(costKilo, cost),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget selectAppliance() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0), // Add padding around the text
            child: Text(
              'Select Appliance Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
    int daysUsed = 0;

    void incrementDays() {
      if (daysUsed < 7) {
        daysUsed++;
      }
    }

    void decrementDays() {
      if (daysUsed > 0) {
        daysUsed--;
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Usage Frequency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Container(
                height: 98,
                width: 315,
                decoration: greyBoxDecoration(),
                // decoration: BoxDecoration(
                //   color: Colors.grey,
                //   borderRadius: BorderRadius.circular(15.0),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.grey.withOpacity(0.3),
                //       blurRadius: 10,
                //       offset: const Offset(0, 5),
                //     ),
                //   ],
                // ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Days Used Per Week',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 30),
                          onPressed: () {
                            setState(() {
                              decrementDays();
                            });
                          },
                        ),
                        Container(
                          width: 150,
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$daysUsed',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 30),
                          onPressed: () {
                            setState(() {
                              incrementDays();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget monthlyUsage() {
    String? daysDropdown;
    String? weekDropdown;
    int daysUsed = 0;

    void incrementDays() {
      if (daysUsed < 7) {
        daysUsed++;
      }
    }

    void decrementDays() {
      if (daysUsed > 0) {
        daysUsed--;
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Monthly Usage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Weekly Usage',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(width: 50),
                        // Days Dropdown
                        CustomDropdown(
                          selectedValue: daysDropdown,
                          defaultValue: 'Days',
                          items: days,
                          onChanged: (String? newValue) {
                            setState(() {
                              daysDropdown = newValue;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        CustomDropdown(
                          selectedValue: weekDropdown,
                          defaultValue: 'Week',
                          items: weeks,
                          onChanged: (String? newValue) {
                            setState(() {
                              weekDropdown = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    averageBill()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget monthlyUsageNotes() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Container(
            height: 217,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: greyBoxDecoration(),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                maxLines: null, // Allows multiline input
                expands: true, // Expands to fill the parent container
                decoration: InputDecoration(
                  labelText: 'Add Notes',
                  hintText: 'Enter your notes',
                  border: InputBorder.none, // Removes underline
                  contentPadding: EdgeInsets.only(
                      top: 12.0, bottom: 12.0), // Adjusts padding
                  alignLabelWithHint: true, // Aligns label with hint
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SignUpButton(
            onPressed: _signUp,
            text: 'Statistics',
          ),
        ],
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
        width: 104,
        height: 40,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.black26 : Colors.grey.withOpacity(0.5),
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Widget averageBill() {
  final TextEditingController _controller = TextEditingController();
  int bill = 0;

  void incrementBill(StateSetter setState) {
    setState(() {
      bill++;
      _controller.text = bill.toString();
    });
  }

  void decrementBill(StateSetter setState) {
    setState(() {
      bill--;
      _controller.text = bill.toString();
    });
  }

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Average Bill',
            style: TextStyle(fontSize: 15),
          ),
          Container(
            decoration: greyBoxDecoration(),
            child: Row(
              children: [
                // Decrement Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, size: 30),
                    onPressed: () {
                      decrementBill(setState);
                    },
                  ),
                ),
                // Input Field
                Container(
                  width: 154,
                  height: 40,
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
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.zero, // Adjust padding to fit
                      ),
                      onChanged: (value) {
                        setState(() {
                          bill = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ),
                // Increment Button
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 30),
                    onPressed: () {
                      incrementBill(setState);
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

class CustomDropdown extends StatefulWidget {
  final String? selectedValue;
  final String defaultValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  CustomDropdown({
    required this.selectedValue,
    required this.defaultValue,
    required this.items,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        decoration: greyBoxDecoration(),
        child: DropdownButton<String>(
          value: widget.selectedValue ?? widget.defaultValue,
          onChanged: (String? newValue) {
            setState(() {
              widget.onChanged(newValue);
            });
          },
          items: [
            if (widget.selectedValue == null)
              DropdownMenuItem<String>(
                value: widget.defaultValue,
                child: Text(widget.defaultValue),
              ),
            ...widget.items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ],
          isExpanded: true,
          underline: const SizedBox(),
        ),
      ),
    );
  }
}
