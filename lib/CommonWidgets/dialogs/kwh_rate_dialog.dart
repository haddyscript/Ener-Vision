import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';

String? _selectedProvider;
final AppControllers controllers = AppControllers();
final Map<String, String> _electricProviders = {
  'Cebu Electric Cooperative': '10.5',
  'Visayan Electric Company (VECO) - Residential': '11.2',
  'Visayan Electric Company (VECO) - Commercial': '15.2',
  'Mactan Electric Company - Residential': '10.8',
  'Mactan Electric Company - Commercial': '13.8',
  'Churba': '12.0',
  'Gengeng': '15.5',
  'Juju on the Beat': '18',
  'Eyy': '33',
  'Waw': '21',
};


Future<void> showKwhRateDialog(
  BuildContext context,
  TextEditingController kwhRateController,
  Function saveKwhRate,
  Function fetchAppliances,
  Function fetchDailyCost,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Enter kWh Rate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.electrical_services,
                  size: 50,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kilowatt-Hour Rate',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    isExpanded: true,
                    hint: const Text('Select your Electric Service Provider'),
                    items: _electricProviders.keys.map((String provider) {
                      return DropdownMenuItem<String>(
                        value: provider,
                        child: Text(
                          provider,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProvider = newValue;
                        controllers.kwhRateController.text =
                            _electricProviders[newValue!]!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: TextField(
                    controller: controllers.kwhRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Kilowatt Hour Rate (kWh)',
                      hintStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                              color: Color(0xFFB1B1B1), width: 1),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontSize: 14.0)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String kwhRate = controllers.kwhRateController.text;

                        try {
                          await saveKwhRate(kwhRate);
                          Navigator.of(context).pop();
                          // _showAddApplianceDialog(context);
                          fetchAppliances();
                          fetchDailyCost();
                        } catch (e) {
                          print('Failed to save kWh rate: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color(0xFF1BBC9B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
