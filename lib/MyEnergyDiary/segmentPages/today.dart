import 'package:flutter/material.dart';

import '../appliances_container.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(height: 20),
        AppliancesContainer(),
      ],
    );
  }
}
