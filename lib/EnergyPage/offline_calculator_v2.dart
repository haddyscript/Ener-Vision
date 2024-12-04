import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/MyEnergyDiary/all_devices_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';

import '../../Buttons/sign_up_button.dart';
import '../CommonWidgets/controllers/app_controllers.dart';

class OfflineCalculatorV2 extends StatefulWidget {
  const OfflineCalculatorV2({super.key});

  @override
  State<OfflineCalculatorV2> createState() => _OfflineCalculatorV2State();
}

class _OfflineCalculatorV2State extends State<OfflineCalculatorV2> {
  final AppControllers controller = AppControllers();
  List<int> selectedDays = [];
  late double result = 0;
  double monthlyCost = 0;
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectedDays();
  }

  void _initializeSelectedDays() {
    final currentDay = DateTime.now().weekday % 7;
    setState(() {
      selectedDays = [currentDay + 1];
    });
  }

  void _calculateMonthlyCost() {
    final wattage = double.tryParse(controller.addWattageController.text) ?? 0;
    final usagePatternPerDay =
        double.tryParse(controller.addUsagePatternController.text) ?? 0;
    final kwhRate = double.tryParse(controller.kwhRateController.text) ?? 0;

    // Number of days in the current month
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Calculate total days used
    final totalDaysUsed = daysInMonth ~/ 7 * selectedDays.length +
        selectedDays.where((day) => day <= daysInMonth % 7).length;

    // Calculate total hours used in the month
    final totalHoursUsed = totalDaysUsed * usagePatternPerDay;

    // Calculate energy in kWh
    final energyKwh = (wattage / 1000) * totalHoursUsed;

    // Calculate monthly cost
    setState(() {
      monthlyCost = energyKwh * kwhRate;
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
        appBar: AppBar(),
        body: SafeArea(child: content()),
      ),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          topSection(),
          usageFrequency(),
          monthlyUsage(),
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
            pageTitle,
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Text(
              pageTitleDescription,
              style: TextStyle(color: Colors.white, letterSpacing: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget usageFrequency() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldTitles(
                energyCostEstimate, energyCalculationParametersExplainer),
            Center(
              child: Container(
                height: 98,
                width: 315,
                decoration: greyBoxDecoration(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        estimatedEnergyCost,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '₱ ${monthlyCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20),
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

  Widget _fieldTitles(String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget monthlyUsage() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldTitles(energyCalculationParameters,
                  energyCalculationParametersExplainer),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CalculatorTextField(
                      title: wattage,
                      labelText: wattageLabelText,
                      placeholder: wattagePlaceholder,
                      controller: controller.addWattageController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.length > 5) {
                          controller.addWattageController.text =
                              value.substring(0, 5);
                          controller.addWattageController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: controller
                                      .addWattageController.text.length));
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the wattage';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    CalculatorTextField(
                      title: usagePattern,
                      labelText: usagePatternText,
                      placeholder: usagePatternPlaceholder,
                      controller: controller.addUsagePatternController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final doubleValue = double.tryParse(value);
                        if (doubleValue != null && doubleValue > 24) {
                          controller.addUsagePatternController.text = '24';
                          controller.addUsagePatternController.selection =
                              TextSelection.fromPosition(
                            const TextPosition(offset: '24'.length),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the usage pattern';
                        }
                        return null;
                      },
                    ),
                    CalculatorTextField(
                      title: kwhRate,
                      labelText: kwhRateText,
                      placeholder: kwhRatePlaceholder,
                      controller: controller.kwhRateController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.length > 4) {
                          controller.kwhRateController.text =
                              value.substring(0, 4);
                          controller.kwhRateController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: controller
                                      .kwhRateController.text.length));
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the usage pattern';
                        }
                        return null;
                      },
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        _selectDaysRow(),
                        const SizedBox(height: 10),
                        // _selectDays(days, 5, 7),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _calculateMonthlyCost,
                      child: const Text(calculateMonthlyCostButton),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _selectDaysRow() {
    final days = ["S", "M", "T", "W", "Th", "F", "St"];
    return Column(
      children: [
        // Row for "Select All" button
        GestureDetector(
          onTap: _toggleSelectAll,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.select_all,
                  color: isAllSelected ? AppColors.primaryColor : Colors.black),
              const SizedBox(width: 8),
              Text(
                selectDays,
                style: TextStyle(
                  color: isAllSelected ? AppColors.primaryColor : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row for individual days
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final dayNum = index + 1;
            final isSelected = selectedDays.contains(dayNum);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => _toggleDay(dayNum),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      isSelected ? AppColors.primaryColor : Colors.grey[300],
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        // Deselect all days
        selectedDays.clear();
        isAllSelected = false;
      } else {
        // Select all days
        selectedDays = [1, 2, 3, 4, 5, 6, 7];
        isAllSelected = true;
      }
    });
  }
}

class CalculatorTextField extends StatelessWidget {
  final String title;
  final String labelText;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CalculatorTextField({
    Key? key,
    required this.title,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    required this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
