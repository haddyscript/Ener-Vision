import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/all_imports/imports.dart';
import 'addGoalPage.dart';
import 'dart:async';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List goals = [];
  String? userId;
  bool isLoading = true;
  DateTime? selectedDate = DateTime.now();
  Timer? _refreshTimer;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 1));
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(() {
      if (_tabController!.index == 1) {
        _triggerConfetti();
      }
    });

    selectedDate = DateTime.now();
    _loadUserIdAndFetchGoals();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      fetchGoals();
    });
  }

  Future<void> _loadUserIdAndFetchGoals() async {
    String? userId = await UserService.getUserId();

    if (userId != null) {
      setState(() {
        this.userId = userId; // Assign the userId for the API call
      });
      await fetchGoals();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _triggerConfetti() {
    _confettiController.play();
  }

  Future<void> fetchGoals({DateTime? filterDate}) async {
    if (userId == null) {
      print('User ID is null. Cannot fetch goals.');
      return;
    }

    try {
      final DateTime targetDate = filterDate ?? DateTime.now();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(targetDate);

      final String url =
          '${ApiConfig.baseUrl}/goals?userId=$userId&date=$formattedDate';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final fetchedGoals = json.decode(response.body);
        setState(() {
          if (fetchedGoals is List && fetchedGoals.isNotEmpty) {
            // Parse the startDate as DateTime, then sort by it
            goals = fetchedGoals
                .map((goal) => {
                      ...goal,
                      'startDate': DateTime.parse(goal['startDate']),
                    })
                .toList()
              ..sort((a, b) => (b['startDate'] as DateTime).compareTo(
                  a['startDate'] as DateTime)); // Sorting by DateTime
          } else {
            goals = [];
          }
          isLoading = false;
        });
        print("Fetched goals: $goals");
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List filterGoalsAll(String filter) {
    switch (filter) {
      case 'Completed':
        return goals.where((goal) => goal['status'] == 'Accomplished').toList();
      case 'Missed':
        return goals.where((goal) => goal['status'] == 'Missed').toList();
      case 'Started':
        return goals.where((goal) => goal['status'] == 'Missed').toList();
      case 'Ended':
        return goals.where((goal) => goal['status'] == 'Missed').toList();    case 'Pending':
        return goals.where((goal) => goal['status'] == 'Missed').toList();
      case 'All':
      default:
        return goals;
    }
  }

  List filterGoals(String filter) {
    final now = DateTime.now();
    final DateTime startOfDay =
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    switch (filter) {
      case 'Completed':
        return goals.where((goal) {
          DateTime goalEndDate = DateTime.parse(goal['endDate']);
          return goal['status'] == 'Accomplished' &&
              goalEndDate.isAfter(startOfDay) &&
              goalEndDate.isBefore(endOfDay);
        }).toList();
      case 'Missed':
        return goals.where((goal) {
          DateTime goalEndDate = DateTime.parse(goal['endDate']);
          return goal['status'] == 'Missed' &&
              goalEndDate.isBefore(now) &&
              goalEndDate.isAfter(startOfDay) &&
              goalEndDate.isBefore(endOfDay);
        }).toList();
      case 'Started':
        return goals.where((goal) {
          DateTime goalEndDate = DateTime.parse(goal['endDate']);
          return goal['status'] == 'Started' &&
              goalEndDate.isAfter(startOfDay) &&
              goalEndDate.isBefore(endOfDay);
        }).toList();
      default:
        return goals.where((goal) {
          DateTime goalEndDate = DateTime.parse(goal['endDate']);
          return goalEndDate.isAfter(startOfDay) &&
              goalEndDate.isBefore(endOfDay);
        }).toList();
    }
  }

  // List filterGoals(String filter) {
  //   final now = DateTime.now();
  //   final DateTime startOfDay =
  //       DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
  //   final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
  //
  //   switch (filter) {
  //     case 'Completed':
  //       return goals.where((goal) {
  //         DateTime goalEndDate = DateTime.parse(goal['endDate']);
  //         return goal['status'] == 'Accomplished' &&
  //             goalEndDate.isAfter(startOfDay) &&
  //             goalEndDate.isBefore(endOfDay);
  //       }).toList();
  //     case 'Missed':
  //       return goals.where((goal) {
  //         DateTime goalEndDate = DateTime.parse(goal['endDate']);
  //         return goal['status'] == 'Missed' &&
  //             goalEndDate.isBefore(now) &&
  //             goalEndDate.isAfter(startOfDay) &&
  //             goalEndDate.isBefore(endOfDay);
  //       }).toList();
  //     case 'Started':
  //       return goals.where((goal) {
  //         DateTime goalEndDate = DateTime.parse(goal['endDate']);
  //         return goal['status'] == 'Started' &&
  //             goalEndDate.isAfter(startOfDay) &&
  //             goalEndDate.isBefore(endOfDay);
  //       }).toList();
  //     default:
  //       return goals.where((goal) {
  //         DateTime goalEndDate = DateTime.parse(goal['endDate']);
  //         return goalEndDate.isAfter(startOfDay) &&
  //             goalEndDate.isBefore(endOfDay);
  //       }).toList();
  //   }
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1BBC9B),
            hintColor: const Color(0xFF1BBC9B),
            colorScheme: const ColorScheme.light(primary: Color(0xFF1BBC9B)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await fetchGoals(filterDate: selectedDate);
    }
  }

  Future<void> addGoal(BuildContext context) async {
    final DateTime now = DateTime.now();
    if (selectedDate != null &&
        (selectedDate!.isBefore(now) || selectedDate!.isAtSameMomentAs(now))) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddGoalPage(selectedDate: selectedDate!),
        ),
      );
      await fetchGoals();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You cannot add goals before today or for past dates.'),
      ));
    }
  }

  Future<void> updateGoalStatus(String goalId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/goals/$goalId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await fetchGoals();
      } else {
        throw Exception('Failed to update goal status');
      }
    } catch (error) {
      print('Error updating status: $error');
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Accomplished':
        return Icons.check_circle;
      case 'Started':
        return Icons.play_circle_outline;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Missed':
        return Icons.cancel;
      case 'Ended':
        return Icons.timelapse;
      default:
        return Icons.help;
    }
  }

  Future<void> _showSuccessOrFailureDialog(
      BuildContext context, String goalId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Goal Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Did you accomplish the goal?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await updateGoalStatus(goalId, 'Accomplished');

                    // Trigger the confetti and show the success dialog
                    _confettiController.play();
                    Navigator.pop(
                        context); // Close the _showSuccessOrFailureDialog

                    // Now show the success dialog
                    _showSuccessDialog(context, goalId); // Show success dialog
                  },
                  child: const Text(
                    'Success',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BBC9B),
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                ),
                const SizedBox(width: 3.0),
                ElevatedButton(
                  onPressed: () async {
                    await updateGoalStatus(goalId, 'Missed');
                    Navigator.pop(context);

                    _showFailureDialog(context, goalId);
                  },
                  child: const Text(
                    'Failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.sentiment_satisfied_alt,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Success',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🌟 Great work! 🌟\nYou’ve successfully achieved your energy-saving target.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),
                // Continue Button
                ElevatedButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFailureDialog(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red Circle with sad face icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                // Failure Text
                const Text(
                  'Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '⚠️ You missed the goal, but keep pushing forward!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// The main goal list screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar1(
        title: 'Daily Energy Goals',
       showBackArrow: false,
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
      body: Stack(
        children: [
          Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  // Tab(text: 'Pending'),
                  // Tab(text: 'Started'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Missed'),
                ],
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    const Text(
                      'Show All Goals',
                      style: AppTheme.subTitleTextStyle,
                    ),
                    Checkbox(
                      tristate: false,
                      value: isChecked,
                      activeColor: isChecked ? AppColors.primaryColor : null,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                    ),
                    const Spacer(),
                    isChecked
                        ? const SizedBox.shrink()
                        : ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(selectedDate!),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8.0),
                                const Icon(Icons.filter_alt_outlined),
                              ],
                            ),
                          ),

                    // ElevatedButton(
                    //   onPressed: () => _selectDate(context),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Text(
                    //         DateFormat('MMM dd, yyyy').format(selectedDate!),
                    //         style: const TextStyle(fontSize: 16),
                    //       ),
                    //       const SizedBox(width: 8.0),
                    //       const Icon(Icons.filter_alt_outlined),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: ['All', 'Completed', 'Missed'].map((filter) {
                          // Determine which filtering function to use based on isChecked
                          final filteredGoals = isChecked
                              ? filterGoalsAll(filter)
                              : filterGoals(filter);

                          // Return the appropriate widget based on filtered goals
                          return filteredGoals.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No added goals found for ${DateFormat('MMM dd, yyyy').format(selectedDate!)}.',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredGoals.length,
                                  itemBuilder: (context, index) {
                                    final goal = filteredGoals[index];
                                    final String status = goal['status'];

                                    Color cardColor;
                                    Color borderColor;
                                    Color iconColor;
                                    Color textColor;

                                    switch (status) {
                                      case 'Accomplished':
                                        cardColor = Colors.green.shade50;
                                        borderColor = Colors.green.shade700;
                                        iconColor = Colors.green.shade700;
                                        textColor = Colors.green.shade700;
                                        break;
                                      case 'Started':
                                        cardColor = Colors.orange.shade50;
                                        borderColor = Colors.orange.shade700;
                                        iconColor = Colors.orange.shade700;
                                        textColor = Colors.orange.shade700;
                                        break;
                                      case 'Pending':
                                        cardColor = Colors.blueGrey.shade50;
                                        borderColor = Colors.blueGrey.shade700;
                                        iconColor = Colors.blueGrey.shade700;
                                        textColor = Colors.blueGrey.shade700;
                                        break;
                                      case 'Missed':
                                        cardColor = Colors.red.shade50;
                                        borderColor = Colors.red.shade700;
                                        iconColor = Colors.red.shade700;
                                        textColor = Colors.red.shade700;
                                        break;
                                      case 'Ended':
                                        cardColor = Colors.blue.shade50;
                                        borderColor = Colors.blue.shade700;
                                        iconColor = Colors.blue.shade700;
                                        textColor = Colors.blue.shade700;
                                        break;
                                      default:
                                        cardColor = Colors.white;
                                        borderColor = Colors.grey;
                                        iconColor = Colors.black;
                                        textColor = Colors.black;
                                        break;
                                    }

                                    return Card(
                                      margin: const EdgeInsets.all(10.0),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: borderColor,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      elevation: 3,
                                      color: cardColor,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        leading: Icon(
                                          getStatusIcon(status),
                                          color: iconColor,
                                        ),
                                        title: Text(
                                          goal['description'] ??
                                              'No description',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              'Category: ${goal['category']}',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey[600]),
                                            ),
                                            isChecked
                                                ? (goal['startDate'] != null
                                                    ? Text(
                                                        'Start Date: ${DateFormat('MMM dd, yyyy').format(
                                                          goal['startDate']
                                                                  is DateTime
                                                              ? goal[
                                                                  'startDate'] // If already DateTime, use it directly
                                                              : DateTime.parse(goal[
                                                                  'startDate']), // Otherwise, parse the string
                                                        )}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      )
                                                    : const SizedBox
                                                        .shrink()) // If startDate is null, return an empty widget
                                                : const SizedBox
                                                    .shrink(), // If isChecked is false, return an empty widget

                                            Text(
                                              'Start: ${goal['startTime']} - End: ${goal['endTime']}',
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                            Text(
                                              'Status: ${goal['status']}',
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        trailing: (status == 'Ended')
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.info,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  _showSuccessOrFailureDialog(
                                                      context, goal['_id']);
                                                },
                                              )
                                            : PopupMenuButton<String>(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                onSelected: (value) async {
                                                  if (value == 'Delete') {
                                                    _showDeleteConfirmationDialog(
                                                        context, goal['_id']);
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem<String>(
                                                    value: 'Delete',
                                                    child: Text('Delete',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                );
                        }).toList(),
                      ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.green, Colors.blue, Colors.orange, Colors.pink],
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addGoal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String goalId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            child: Text(
              'Are you sure you want to permanently delete this goal? This action cannot be undone.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                bool isDeleted = await deleteGoal(goalId);

                if (isDeleted) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSuccessPrompt(context);
                  }
                } else {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/goals/$goalId'),
      );

      if (response.statusCode == 200) {
        await fetchGoals();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Error deleting goal: $error');
      return false;
    }
  }

  void _showSuccessPrompt(BuildContext context) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green[600], size: 30),
                const SizedBox(width: 10),
                const Text(
                  'Success',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1BBC9B),
                  ),
                ),
              ],
            ),
            content: const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: Text(
                'The goal has been successfully deleted.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBC9B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
