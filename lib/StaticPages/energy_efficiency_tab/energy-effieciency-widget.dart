import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/static_page_shared_widgets.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';

import '../../CommonWidgets/appbar-widget.dart';

class EnergyEfficiencyWidget extends StatelessWidget {
  const EnergyEfficiencyWidget({super.key, required int selectedIndex});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Energy Efficiency',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: content(context),
      ),
    );
  }

  Widget content(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          firstParagraph(context,
              'Energy efficiency  means using less energy to perform the same task. This reduces energy waste, lowers costs, and benefits the environment.'),
          firstParagraph(context,
              '  This means using less energy to get the same job done – and in the process, cutting energy bills and reducing pollution. Many products, homes, and buildings use more energy than they actually need, through inefficiencies and energy waste.'),
          bigImageContainer(context, 'assets/image0.png'),
          header(context, 'Key Areas of Energy Efficiency'),
          bottomDescription(
            context,
            'APPLIANCES',
            'Use energy-efficient appliances like refrigerators, washing machines, and air conditioners with high energy ratings.',
            '',
            'assets/energy1.png',
            true,
          ),
          bottomDescription(
            context,
            'LIGHTING',
            'Switch to LED bulbs, which use less energy and last longer than traditional incandescent bulbs.',
            '',
            'assets/energy1.png',
            false,
          ),
          bottomDescription(
            context,
            'HEATING AND COOLING',
            'Burns cleaner than coal and oil but still emits greenhouse gases.',
            '',
            'assets/energy1.png',
            true,
          ),
          bottomDescription(
            context,
            'BUILDING DESIGN',
            'Incorporate energy-efficient windows, doors, and insulation in building designs.',
            '',
            'assets/energy1.png',
            false,
          ),
          bottomDescription(
            context,
            'Renewable Energy Sources',
            'Implement solar panels or wind turbines to generate renewable energy and decrease reliance on fossil fuels.',
            '',
            'assets/energy1.png',
            true,
          ),
          header(context, 'Benefits of Energy Efficiency'),
          benefits(
              context,
              '1. Cost Savings. Lower energy bills due to reduced energy consumption.',
              '2. Environmental Impact. Decreases greenhouse gas emissions and pollution. ',
              '3.Increased Comfort. Better insulation and efficient systems enhance living conditions.',
              '4. Enhanced Energy Security. Reduces dependence on imported energy.'),
          header(context, 'How Can you contribute?'),
          benefits(
              context,
              'Upgrade Appliances. Choose energy-efficient models when replacing old appliances.',
              'Conduct Energy Audits. Regularly check your home for energy efficiency improvements.',
              'Support Green Initiatives. Advocate for and participate in local energy-saving programs.',
              ''),
        ],
      ),
    );
  }
}
