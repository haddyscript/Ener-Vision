class EnergyCalculator {
  final List<Map<String, dynamic>> appliances;

  EnergyCalculator(this.appliances);

  double calculateTotalKWhPerDay() {
    double totalKWh = 0.0;
    for (var appliance in appliances) {
      double wattage = appliance['wattage'];
      int usagePattern = appliance['usagePattern'];
      totalKWh += (wattage * usagePattern) / 1000; // kWh for 1 day
    }
    return totalKWh;
  }

  // Method to calculate total daily energy consumption in kWh
  // energy_calculator.dart
  double calculateDailyEnergyConsumption(
      List<Map<String, dynamic>> appliances) {
    double totalDailyKWh = 0.0;
    for (var appliance in appliances) {
      double wattage = appliance['wattage'];
      int usagePattern = appliance['usagePattern'];
      totalDailyKWh += (wattage * usagePattern) / 1000;
    }
    return totalDailyKWh;
  }

  // Method to calculate total monthly energy consumption in kWh
  double calculateMonthlyEnergyConsumption(
      List<Map<String, dynamic>> appliances) {
    double totalMonthlyKWh = 0.0;
    for (var appliance in appliances) {
      double wattage = appliance['wattage'];
      int usagePattern = appliance['usagePattern'];
      totalMonthlyKWh +=
          (wattage * usagePattern * 30) / 1000; // kWh for 30 days
    }
    return totalMonthlyKWh;
  }

  // Method to calculate daily cost of energy consumption
  double calculateDailyCost(List<Map<String, dynamic>> appliances) {
    const double costPerKWh = 18.0; // Cost per kWh in your currency
    return calculateDailyEnergyConsumption(appliances) * costPerKWh;
  }

  // Method to calculate monthly cost of energy consumption
  double calculateMonthlyCost(List<Map<String, dynamic>> appliances) {
    const double costPerKWh = 18.0; // Cost per kWh in your currency
    return calculateMonthlyEnergyConsumption(appliances) * costPerKWh;
  }
}
