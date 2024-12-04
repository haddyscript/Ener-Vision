import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class ApplianceInformationDialog extends StatefulWidget {
  final Map<String, dynamic> appliance;

  const ApplianceInformationDialog({
    Key? key,
    required this.appliance,
  }) : super(key: key);

  @override
  State<ApplianceInformationDialog> createState() =>
      _ApplianceInformationDialogState();
}

class _ApplianceInformationDialogState extends State<ApplianceInformationDialog>
    with SingleTickerProviderStateMixin {
  final formatter = NumberFormat('#,##0.00', 'en_PHP');

  // Days mapped to Sunday through Saturday
  final Map<int, String> dayNames = {
    1: 'Sunday',
    2: 'Monday',
    3: 'Tuesday',
    4: 'Wednesday',
    5: 'Thursday',
    6: 'Friday',
    7: 'Saturday',
  };

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300), // Adjust the duration as needed
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(_controller);

    // Start the animation when the dialog is displayed
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<int>? selectedDays = widget.appliance['selectedDays'] != null
        ? (widget.appliance['selectedDays'] as List)
            .map((day) => int.parse(day.toString()))
            .toList()
        : null;

    // Ensure selectedDays are sorted from Sunday to Saturday before converting to names
    String selectedDaysNames = selectedDays != null
        ? (selectedDays..sort())
            .map((day) => dayNames[day] ?? 'Unknown')
            .join(', ')
        : 'N/A';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/appInfoImage.png',
                        fit: BoxFit.cover,
                        scale: 0.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${widget.appliance['applianceName']}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Column(
                      children: [
                        KeyValueRow(
                          label: 'Wattage       ',
                          valueWidget: Text(
                            '${widget.appliance['wattage'] ?? 'N/A'} W',
                          ),
                        ),
                        KeyValueRow(
                            label: 'Hours Used',
                            valueWidget: Text(
                                ' ${widget.appliance['usagePatternPerDay'] ?? 'hours'} hours')),
                        KeyValueRow(
                          label: "Month's Cost",
                          valueWidget: Text(
                            'PHP ${formatter.format(widget.appliance['monthlyCost'] ?? 0)}',
                          ),
                        ),
                        KeyValueRow(
                          label: 'Selected Days',
                          valueWidget: Wrap(
                            children: [Text(selectedDaysNames)],
                          ),
                        ),
                        updatedAt(
                          'Appliance Added On',
                          widget.appliance['createdAt'] != null
                              ? DateFormat('MM/dd/yyyy').format(
                                  DateTime.parse(widget.appliance['createdAt']),
                                )
                              : '',
                        ),
                        updatedAt(
                          'Last Updated',
                          widget.appliance['updatedAt'] != null
                              ? DateFormat('MM/dd/yyyy').format(
                                  DateTime.parse(widget.appliance['updatedAt']),
                                )
                              : '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget updatedAt(String title, String dateText) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Text(
            dateText,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class KeyValueRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;

  const KeyValueRow({
    Key? key,
    required this.label,
    required this.valueWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            child: valueWidget,
          ),
        ],
      ),
    );
  }
}
