import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/all_imports/imports.dart';

class AddGoalPage extends StatefulWidget {
  final DateTime? selectedDate;

  AddGoalPage({Key? key, this.selectedDate}) : super(key: key);

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final List<String> categories = [
    'Appliance Unplugging',
    'Lighting Management',
    'Screen Time Reduction',
    'Heating and Cooling Optimization',
    'Natural Ventilation and Lighting',
    'Thermostat Adjustments',
    'Efficient Home Tasks',
  ];

  String? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchGoals();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _startDateController.text = currentDate;
    _endDateController.text = currentDate;
  }


  Future<void> _loadUserIdAndFetchGoals() async {
    String? userId = await UserService.getUserId();

    if (userId != null) {
      setState(() {
        this.userId = userId; // Assign the userId for the API call
      });
      // await fetchGoals();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isValidDateTime(DateTime startDateTime, DateTime endDateTime) {
    final now = DateTime.now().toUtc();
    final startTruncated = DateTime(startDateTime.year, startDateTime.month,
        startDateTime.day, startDateTime.hour, startDateTime.minute);
    final endTruncated = DateTime(endDateTime.year, endDateTime.month,
        endDateTime.day, endDateTime.hour, endDateTime.minute);
    final nowTruncated =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    if (startTruncated.isBefore(nowTruncated)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Start time cannot be in the past.")),
      );
      return false;
    }

    if (endTruncated.isBefore(startTruncated)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("End time must be after the start time.")),
      );
      return false;
    }

    return true;
  }

  DateTime _convertTo24HourDateTime(String date, String time) {
    final formatter = DateFormat("yyyy-MM-dd hh:mm a");
    DateTime localDateTime = formatter.parse("$date $time");
    return localDateTime.toUtc();
  }

  Future<void> _addGoal() async {
    if (_descriptionController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields and log in.")),
      );
      return;
    }
    final startDateTime = _convertTo24HourDateTime(
      _startDateController.text,
      _startTimeController.text,
    );
    final endDateTime = _convertTo24HourDateTime(
      _endDateController.text,
      _endTimeController.text,
    );

    if (!_isValidDateTime(startDateTime, endDateTime)) return;

    setState(() {
      isLoading = true;
    });

    final body = jsonEncode({
      "description": _descriptionController.text,
      "startDate": startDateTime.toIso8601String(),
      "endDate": endDateTime.toIso8601String(),
      "startTime": _startTimeController.text,
      "endTime": _endTimeController.text,
      "category": _categoryController.text,
      "userId": userId,
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/goals'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Goal added successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add goal. Please try again.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error adding goal. Please check your network.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1BBC9B),
            hintColor: const Color(0xFF1BBC9B),
            colorScheme: ColorScheme.light(primary: const Color(0xFF1BBC9B)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (selectedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1BBC9B),
            hintColor: const Color(0xFF1BBC9B),
            colorScheme: ColorScheme.light(primary: const Color(0xFF1BBC9B)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (selectedTime != null) {
      controller.text = selectedTime.format(context);
    }
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Select a Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: categories.map((category) {
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  title: Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    _categoryController.text = category;
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar1(
        title: 'Add New Goal',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _descriptionController,
              label: 'Goal Description',
              maxLines: 3,
            ),
            _buildTextField(
              controller: _startDateController,
              label: 'Start Date',
              isReadOnly: true,
            ),
            _buildTextField(
              controller: _endDateController,
              label: 'End Date',
              isReadOnly: true,
            ),
            _buildTextField(
              controller: _startTimeController,
              label: 'Start Time',
              isReadOnly: true,
              onTap: () => _selectTime(_startTimeController),
            ),
            _buildTextField(
              controller: _endTimeController,
              label: 'End Time',
              isReadOnly: true,
              onTap: () => _selectTime(_endTimeController),
            ),
            GestureDetector(
              onTap: _showCategoryDialog,
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _categoryController,
                  label: 'Category',
                  suffixIcon: Icons.arrow_drop_down,
                ),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addGoal,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                      backgroundColor: Color(0xFF1BBC9B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Color(0xFF1BBC9B).withOpacity(0.3),
                    ),
                    child: Text(
                      'Add Goal',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isReadOnly = false,
    int maxLines = 1,
    GestureTapCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            maxLines: maxLines,
            onTap: onTap,
            style: TextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF1BBC9B), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
