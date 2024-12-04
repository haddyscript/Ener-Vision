import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';

class ApplianceListDialog extends StatelessWidget {
  final List<Map<String, dynamic>> appliances;

  const ApplianceListDialog({
    Key? key,
    required this.appliances,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFADE7DB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Appliance List',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              appliances.isEmpty
                  ? Text(
                      'No appliances added.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: appliances.length,
                        itemBuilder: (context, index) {
                          final appliance = appliances[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFADE7DB),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Icons.electrical_services),
                              title: Text(
                                appliance['applianceName'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ApplianceDetail(
                                    label: 'Wattage: ',
                                    value: '${appliance['wattage'] ?? 'N/A'} W',
                                  ),
                                  ApplianceDetail(
                                      label: 'Monthly Cost ',
                                      value:
                                          '${appliance['monthlyCost'].toStringAsFixed(2) ?? 'N/A'}'),
                                  ApplianceDetail(
                                    label: 'Created: ',
                                    value: appliance['createdAt'] != null
                                        ? DateFormat('MM/dd').format(
                                            DateTime.parse(
                                                appliance['createdAt']))
                                        : 'null',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApplianceDetail extends StatelessWidget {
  final String label;
  final String value;

  const ApplianceDetail({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Text(value),
      ],
    );
  }
}
