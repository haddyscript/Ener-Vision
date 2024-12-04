import 'package:flutter/material.dart';

class SuggestionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSubmit;
  final String assetImagePath;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const SuggestionTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSubmit,
    required this.assetImagePath,
    this.margin = const EdgeInsets.all(18.0),
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Image.asset(
              assetImagePath,
              width: 50.0,
              height: 50.0,
            ),
          ),
          const SizedBox(width: 5.0),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
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
            onPressed: () {
              final suggestionText = controller.text;
              if (suggestionText.isNotEmpty) {
                onSubmit(suggestionText);
                controller.clear();
              } else {
                showSnackBar(context, 'Suggestion text cannot be empty');
              }
            },
          ),
        ],
      ),
    );
  }

  // This can be customized or extracted to a separate file if needed
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
