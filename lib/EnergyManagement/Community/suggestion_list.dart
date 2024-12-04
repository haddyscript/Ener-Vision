import 'package:flutter/material.dart';

class SuggestionItem extends StatelessWidget {
  final String username;
  final String suggestion;
  final int index;
  final TextEditingController controller;
  final Function onEditPressed;
  final Function onDeletePressed;

  const SuggestionItem({
    super.key,
    required this.suggestion,
    required this.index,
    required this.controller,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1BBC9B),
                  fontSize: 16.0,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (String value) {
                  if (value == 'Edit') {
                    onEditPressed();
                  } else if (value == 'Delete') {
                    onDeletePressed();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Edit', 'Delete'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          Text(
            suggestion,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionsList extends StatelessWidget {
  final String username;
  final List<String> suggestions;
  final Function(int) onEditPressed;
  final Function(int) onDeletePressed;

  const SuggestionsList({
    super.key,
    required this.username,
    required this.suggestions,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return SuggestionItem(
          suggestion: suggestions[index],
          index: index,
          controller: TextEditingController(text: suggestions[index]),
          onEditPressed: () => onEditPressed(index),
          onDeletePressed: () => onDeletePressed(index),
          username: username,
        );
      },
    );
  }
}
