import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';

class EnergyPowerUsed extends StatelessWidget {
  final int totalDevices;
  final double co2Emission;
  final double estimatedEnergy;
  final String title;
  final String value;
  final List<DeviceInfo> devices;

  const EnergyPowerUsed({
    Key? key,
    this.totalDevices = 0,
    this.co2Emission = 0.0,
    this.estimatedEnergy = 0.0,
    this.devices = const [],
    required this.value,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar1(onBackPressed: () => Navigator.of(context).pop()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Energy Power Used",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: deviceUsageSummary(
                      totalDevices: totalDevices,
                      co2Emission: co2Emission,
                      estimatedEnergy: estimatedEnergy,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: deviceList(devices: devices),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget deviceUsageSummary({
  required int totalDevices,
  required double co2Emission,
  required double estimatedEnergy,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      energyCard(title: "Total Devices", value: totalDevices.toString()),
      const SizedBox(height: 16),
      energyCard(title: "CO2 Emission", value: co2Emission.toStringAsFixed(2)),
      const SizedBox(height: 16),
      energyCard(
        title: "Estimated Energy Used",
        value: "${estimatedEnergy.toStringAsFixed(2)} kW",
      ),
    ],
  );
}

Widget energyCard({required String title, required String value}) {
  return SizedBox(
    width: 120,
    height: 120,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFADE7DB),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          const BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget deviceList({required List<DeviceInfo> devices}) {
  return devices.isEmpty
      ? Center(
          child: Text(
            "No Devices Available",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[600],
            ),
          ),
        )
      : ScrollConfiguration(
          behavior: const ScrollBehavior(),
          child: RawScrollbar(
            padding: const EdgeInsets.only(top: 45.0),
            thumbColor: const Color(0xFF1BBC9B),
            radius: const Radius.circular(8),
            thickness: 10,
            thumbVisibility: true,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                  child: const Text(
                    "All Devices",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0, right: 15.0),
                    itemCount: devices.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return deviceCard(devices[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
}

Widget deviceCard(DeviceInfo device) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color(0xFFADE7DB),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        const BoxShadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.name,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PHP ${device.monthlyCost.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Monthly Cost",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${device.monthlyEnergy} kWh",
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Energy Used",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class DeviceInfo {
  final String name;
  final double monthlyCost;
  final double monthlyEnergy;

  DeviceInfo({
    required this.name,
    required this.monthlyCost,
    required this.monthlyEnergy,
  });
}
