import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../../ConstantTexts/final_texts.dart';

class EditApplianceDialog extends StatefulWidget {
  final TextEditingController editApplianceNameController;
  final TextEditingController editWattageController;
  final TextEditingController editUsagePatternController;
  final TextEditingController editWeeklyPatternController;
  final GlobalKey<FormState> formKey;
  final VoidCallback editAppliance;
  final Map<String, dynamic> appliance;
  final Future<void> Function(String, Map<String, dynamic>) updateAppliance;
  final VoidCallback fetchAppliances;
  final VoidCallback fetchDailyCosts;

  const EditApplianceDialog({
    Key? key,
    required this.editApplianceNameController,
    required this.editWattageController,
    required this.editUsagePatternController,
    required this.formKey,
    required this.editAppliance,
    required this.appliance,
    required this.updateAppliance,
    required this.fetchAppliances,
    required this.fetchDailyCosts,
    required this.editWeeklyPatternController,
  }) : super(key: key);

  @override
  State<EditApplianceDialog> createState() => _EditApplianceDialogState();
}

class _EditApplianceDialogState extends State<EditApplianceDialog> {
  List<int> selectedDays = [];
  final AppControllers controller = AppControllers();
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    // Initialize selectedDays with the data from appliance['selectedDays']
    if (widget.appliance['selectedDays'] != null) {
      selectedDays = List<int>.from(widget.appliance['selectedDays']);
    }
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

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
      print(selectedDays); // Print to debug the selected days
    });
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Appliance Not Updated',
      message: 'Appliance can not be updated twice in a month',
      buttonText: 'OK',
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final days = ["M", "T", "W", "Th", "F", "St", "S"];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: widget.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/dialogImage.png', height: 100, width: 100),
                const SizedBox(height: 20),
                Text(
                  'Current Appliance: ${widget.appliance['applianceName']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: widget.editApplianceNameController,
                  decoration: InputDecoration(
                    labelText: 'Enter New Appliance Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an appliance name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length > 16) {
                      widget.editApplianceNameController.text =
                          value.substring(0, 16);
                      widget.editApplianceNameController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: widget
                                  .editApplianceNameController.text.length));
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.editWattageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Wattage',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length > 6) {
                      widget.editWattageController.text = value.substring(0, 6);
                      widget.editWattageController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset:
                                  widget.editWattageController.text.length));
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.editUsagePatternController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Usage Pattern (hours per day)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (value) {
                    final doubleValue = double.tryParse(value);
                    if (doubleValue != null && doubleValue > 24) {
                      widget.editUsagePatternController.text = '24';
                      widget.editUsagePatternController.selection =
                          TextSelection.fromPosition(
                        const TextPosition(offset: '24'.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the usage pattern';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _toggleSelectAll,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.select_all,
                          color: isAllSelected
                              ? AppColors.primaryColor
                              : Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        selectDays,
                        style: TextStyle(
                          color: isAllSelected
                              ? AppColors.primaryColor
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First row with 4 days
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final dayNum = index + 1;
                        final isSelected = selectedDays.contains(dayNum);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () => _toggleDay(dayNum),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: isSelected
                                  ? AppColors.secondaryColor
                                  : Colors.grey[300],
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final dayNum = index + 5;
                        final isSelected = selectedDays.contains(dayNum);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () => _toggleDay(dayNum),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: isSelected
                                  ? AppColors.secondaryColor
                                  : Colors.grey[300],
                              child: Text(
                                days[dayNum - 1],
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showSnackBar(context, 'Appliance was not updated');
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.formKey.currentState!.validate()) {
                          final updatedAppliance = {
                            'applianceName':
                                widget.editApplianceNameController.text,
                            'wattage':
                                double.parse(widget.editWattageController.text),
                            'usagePatternPerDay': double.parse(
                                widget.editUsagePatternController.text),
                            'selectedDays': selectedDays,
                          };

                          widget
                              .updateAppliance(
                                  widget.appliance['_id'], updatedAppliance)
                              .then((_) {
                            widget.fetchAppliances();
                            widget.fetchDailyCosts();

                            Navigator.of(context).pop();
                            // _showSnackBar(
                            //     context, 'Appliance updated successfully!');
                          }).catchError((error) {
                            // _showApplianceErrorDialog(context);
                            // _showSnackBar(
                            //     context, 'Failed to update appliance');
                          });
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
