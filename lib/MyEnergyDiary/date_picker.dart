import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidgetWithAllMonths extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback getApplianceCount;

  const DatePickerWidgetWithAllMonths({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.getApplianceCount,
  });

  @override
  _DatePickerWidgetWithAllMonthsState createState() =>
      _DatePickerWidgetWithAllMonthsState();
}

class _DatePickerWidgetWithAllMonthsState
    extends State<DatePickerWidgetWithAllMonths> {
  late List<String> months;
  late List<int> years;

  String? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();

    months = List.generate(
      12,
      (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
    );

    years = List.generate(10, (index) => DateTime.now().year - index);

    selectedMonth = DateFormat('MMMM').format(widget.initialDate);
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM yyyy').format(widget.initialDate);

    return GestureDetector(
      onTap: () => _showMonthYearPicker(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                formattedDate,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.calendar_month, size: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    String tempSelectedMonth = selectedMonth!;
    int tempSelectedYear = selectedYear!;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SELECT MONTH AND YEAR',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: tempSelectedMonth,
                          onChanged: (String? newMonth) {
                            if (newMonth != null) {
                              setState(() {
                                tempSelectedMonth = newMonth;
                              });
                            }
                          },
                          items: months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                        ),
                        DropdownButton<int>(
                          value: tempSelectedYear,
                          onChanged: (int? newYear) {
                            if (newYear != null) {
                              setState(() {
                                tempSelectedYear = newYear;
                              });
                            }
                          },
                          items: years.map((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            int monthIndex =
                                months.indexOf(tempSelectedMonth) + 1;

                            DateTime newDate =
                                DateTime(tempSelectedYear, monthIndex);

                            widget.onDateSelected(newDate);
                            widget.getApplianceCount();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
