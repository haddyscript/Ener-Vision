import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';

class DeviceInfoPage extends StatelessWidget {
  final Map<String, dynamic> device;
  DeviceInfoPage({required this.device});
  Widget buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: const Color(0xFF1BBC9B),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar4(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1BBC9B), width: 1.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                device['deviceName'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25.0),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.speaker,
                size: 50,
                color: Color(0xFF1BBC9B),
              ),
            ),
            const SizedBox(height: 25.0),
            buildSectionHeader('DESCRIPTION'),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                device['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 14.0),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20.0),
            buildSectionHeader('DEVICE INFORMATION'),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow('Price', '₱${device['purchasePrice']}'),
                  buildInfoRow('Capacity', device['capacity']),
                  buildInfoRow('Material', device['material']),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            buildSectionHeader('ENERGY EFFICIENCY DETAILS'),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow(
                      'Power Consumption', '${device['powerConsumption']}'),
                  buildInfoRow(
                      'Estimated Cost per Hour', '₱${device['costPerHour']}'),
                  buildInfoRow('Estimated Monthly Cost', device['monthlyCost']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
