import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class AddApplianceDialog extends StatefulWidget {
  final TextEditingController addApplianceNameController;
  final TextEditingController addWattageController;
  final TextEditingController addUsagePatternController;
  final TextEditingController addWeeklyPatternController;
  final TextEditingController addApplianceCategoryController;
  final GlobalKey<FormState> formKey;
  final VoidCallback addAppliance;
  const AddApplianceDialog({
    Key? key,
    required this.addApplianceNameController,
    required this.addWattageController,
    required this.addUsagePatternController,
    required this.formKey,
    required this.addAppliance,
    required this.addWeeklyPatternController,
    required this.addApplianceCategoryController,
  }) : super(key: key);

  @override
  State<AddApplianceDialog> createState() => _AddApplianceDialogState();
}

class _AddApplianceDialogState extends State<AddApplianceDialog> {
  List<int> selectedDays = [];
  final AppControllers controller = AppControllers();

  @override
  void initState() {
    super.initState();
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
        print(selectedDays);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = ["M", "T", "W", "Th", "F", "St", "S"];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Form(
                key: widget.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    popupTitle(),
                    const SizedBox(height: 20),
                    textFormFields(),
                    const SizedBox(height: 20),
                    const Text("Select Days", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: List.generate(days.length, (index) {
                        final dayNum = index + 1;
                        final isSelected = selectedDays.contains(dayNum);

                        return GestureDetector(
                          onTap: () => _toggleDay(dayNum),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: isSelected
                                ? AppColors.secondaryColor
                                : Colors.grey[300],
                            child: Text(
                              days[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    actionButtons(context)
                  ],
                ),
              ),
            ),
            topImage()
          ],
        ),
      ),
    );
  }

  Widget popupTitle() {
    return const Text('Add Appliance To Track',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ));
  }

  Widget textFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add horizontal padding
      child: Column(
        children: [
          TextFormField(
            controller: widget.addApplianceNameController,
            decoration: InputDecoration(
              labelText: 'Appliance Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              if (value.length > 16) {
                widget.addApplianceNameController.text = value.substring(0, 16);
                widget.addApplianceNameController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: widget.addApplianceNameController.text.length));
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an appliance name';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          DropdownWithIcon(
            labelText: 'Appliance Category',
            items: const [
              'Personal Devices',
              'Kitchen Appliances',
              'Cleaning & Laundry Appliances',
              'Personal Care Appliances',
              'Home Media and Office Appliances',
              'Climate and Lighting Control Appliances'
            ],
            controller: widget.addApplianceCategoryController,
            icon: Icons.arrow_drop_down, // Specify the icon you want to display
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an appliance category';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.addWattageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Wattage',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) {
              if (value.length > 4) {
                widget.addWattageController.text = value.substring(1, 4);
                widget.addWattageController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: widget.addWattageController.text.length));
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
            controller: widget.addUsagePatternController,
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
                widget.addUsagePatternController.text = '24';
                widget.addUsagePatternController.selection =
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
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.addWeeklyPatternController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Days used per Week',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) {
              final doubleValue = double.tryParse(value);
              if (doubleValue != null && doubleValue > 7) {
                widget.addWeeklyPatternController.text = '7';
                widget.addWeeklyPatternController.selection =
                    TextSelection.fromPosition(
                  const TextPosition(offset: '7'.length),
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
        ],
      ),
    );
  }

  Widget actionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (widget.formKey.currentState!.validate()) {
              widget.addAppliance();
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget topImage() {
    return Positioned(
      top: -70.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        width: 140,
        height: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset('assets/dialogImage.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class DropdownWithIcon extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final TextEditingController controller;
  final IconData icon;
  final FormFieldValidator<String>? validator;

  const DropdownWithIcon({
    Key? key,
    required this.labelText,
    required this.items,
    required this.controller,
    required this.icon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty ? controller.text : null,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              suffixIcon: Icon(icon),
            ),
            items: items.map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
              }
            },
            validator: validator,
          ),
        ),
      ],
    );
  }
}
