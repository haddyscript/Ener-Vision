import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';

class TotalCostDisplay extends StatelessWidget {
  final String cost;

  const TotalCostDisplay({
    super.key,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 153,
      decoration: greyBoxDecoration(),
      child: Center(
        child: Text(
          cost,
        ),
      ),
    );
  }
}

class EstimatedDisplay extends StatelessWidget {
  final String cost;
  final String texts;
  const EstimatedDisplay({
    super.key,
    required this.cost,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 153,
      decoration: greyBoxDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cost,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              textAlign: TextAlign.center,
              texts,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
