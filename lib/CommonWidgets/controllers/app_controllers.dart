import 'package:flutter/material.dart';

class AppControllers {
  // Edit Appliance Controllers
  final TextEditingController editApplianceNameController =
      TextEditingController();
  final TextEditingController editWattageController = TextEditingController();
  final TextEditingController editUsagePatternController =
      TextEditingController();
  final TextEditingController editWeeklyPatternController =
      TextEditingController();

  // Add Appliance Controllers
  final TextEditingController addApplianceNameController =
      TextEditingController();
  final TextEditingController addWattageController = TextEditingController();
  final TextEditingController addUsagePatternController =
      TextEditingController();
  final TextEditingController addWeeklyPatternController =
      TextEditingController();
  final TextEditingController addApplianceCategoryController =
      TextEditingController();
  final TextEditingController kwhRateController = TextEditingController();
  final TextEditingController addMonthlyPatternController =
      TextEditingController();
  final TextEditingController suggestionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Dispose all controllers
  void dispose() {
    editApplianceNameController.dispose();
    editWattageController.dispose();
    editUsagePatternController.dispose();
    editWeeklyPatternController.dispose();
    addApplianceNameController.dispose();
    addWattageController.dispose();
    addUsagePatternController.dispose();
    addWeeklyPatternController.dispose();
    addApplianceCategoryController.dispose();
    kwhRateController.dispose();
    addMonthlyPatternController.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
  }
}
