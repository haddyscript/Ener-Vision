import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../../ConstantTexts/final_texts.dart';

class EnergyTrackerWidget extends StatefulWidget {
  final int selectedIndex;
  const EnergyTrackerWidget({Key? key, required this.selectedIndex})
      : super(key: key);

  @override
  _EnergyTrackerWidgetState createState() => _EnergyTrackerWidgetState();
}

class _EnergyTrackerWidgetState extends State<EnergyTrackerWidget> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();
  double _sliderValue = 0.5;

  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    controller3.dispose();

    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = -1;

    return Scaffold(
      bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // height: 652,
            child: Column(
              children: [
                Container(
                  height: 258,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Energy Tracker",
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          child: Text(
                            energyTrackerExplainer,
                            style: TextStyle(
                                color: Colors.white, letterSpacing: 1.5),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 320,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            color: Colors.white,
                          ),
                          child: const Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'BEGIN BY COMPLETING THIS FORM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Divider(
                                color: Colors.black,
                                thickness: 2,
                                indent: 0,
                                endIndent: 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 76,
                  width: 289,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Appliance',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                                hintText: "Enter Appliance Name",
                                prefixIcon: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.telegram)),
                                suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.arrow_drop_down),
                                ),
                                focusedBorder: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 289,
                  height: 94,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Wattage',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'This is the appliance\'s power rating',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                child: TextField(
                                  focusNode: focusNode1,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode2);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 24,
                                child: TextField(
                                  focusNode: focusNode2,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode3);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 24,
                                child: TextField(
                                  focusNode: focusNode3,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode4);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    focusedBorder: InputBorder.none,
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

                // This is for the Hours used per day container
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 289,
                  height: 94,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Hours used per day',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'How many hours does the appliance run daily?',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                child: TextField(
                                  focusNode: focusNode4,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode5);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 24,
                                child: TextField(
                                  focusNode: focusNode5,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  decoration: const InputDecoration(
                                    focusedBorder: InputBorder.none,
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
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 289,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              _sliderValue =
                                  (_sliderValue - 0.1).clamp(0.0, 1.0);
                            });
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: _sliderValue,
                            onChanged: (double newValue) {
                              setState(() {
                                _sliderValue = newValue;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _sliderValue =
                                  (_sliderValue + 0.1).clamp(0.0, 1.0);
                            });
                          },
                        ),
                        // AddApplianceButton(
                        //   text: 'Add Appliance',
                        //   onPressed: () {},
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
