import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onRefreshTap;

  const TopBar({
    Key? key,
    required this.onEditTap,
    required this.onRefreshTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: greyBoxDecoration(),
        width: double.infinity,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share your insight',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 10.0),
            GestureDetector(
              onTap: onEditTap, // Calls the onEditTap callback
              child: const Icon(Icons.edit),
            ),
            GestureDetector(
              onTap: onRefreshTap, // Calls the onRefreshTap callback
              child: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
