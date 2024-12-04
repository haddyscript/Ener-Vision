// confirm_delete_dialog.dart

import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class SuggestionField extends StatelessWidget {
  const SuggestionField({super.key});

  @override
  Widget build(BuildContext context) {
    AppControllers controller = AppControllers();

    return Container(
      margin: const EdgeInsets.all(18.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 2.0),
                child: Image(
                  image: AssetImage('assets/suggestion.png'),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
              const SizedBox(width: 5.0),
              Expanded(
                child: TextField(
                  controller: controller.suggestionController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Suggest changes or additional tips...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Color(0xFF1BBC9B),
                  size: 24,
                ),
                onPressed: () async {
                  final suggestionText = controller.suggestionController.text;

                  if (suggestionText.isNotEmpty) {
                    try {
                      showSnackBar(context, 'Suggestion added successfully');
                      controller.suggestionController
                          .clear(); // Clear the text field after successful submission
                    } catch (e) {
                      showSnackBar(context, 'Failed to add suggestion: $e');
                    }
                  } else {
                    showSnackBar(context, 'Suggestion text cannot be empty');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String description;
  final Future<void> Function() onDelete;
  final Future<void> Function() postDelete;

  const ConfirmDeleteDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.onDelete,
    required this.postDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: AppColors.primaryColor,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onDelete().then((_) {
                      Navigator.of(context).pop();
                      postDelete();
                    }).catchError((error) {
                      print('Deletion failed: $error');
                      Navigator.of(context).pop(); // Close dialog even on error
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
