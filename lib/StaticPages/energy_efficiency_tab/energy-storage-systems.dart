import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/static_page_shared_widgets.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';

import '../../CommonWidgets/appbar-widget.dart';

class EnergyStorage extends StatelessWidget {
  const EnergyStorage({super.key, required int selectedIndex});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Energy Storage',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              firstParagraph(context,
                  'Energy storage  systems store excess energy generated during times of low demand for use during peak demand periods, enhancing grid stability and enabling greater integration of renewable energy sources.'),
              firstParagraph(context,
                  'Energy storage  is the capture of energy produced at one time for use at a later time to reduce imbalances between energy demand and energy production.'),
              bigImageContainer(context, 'assets/image0.png'),
              header(context, 'Types of Energy Storage'),
              bottomDescription(
                context,
                'Battery Storage',
                'Stores electricity in rechargeable batteries for later use.',
                'Commonly used in homes, businesses, and electric vehicles.',
                'assets/energy1.png',
                true,
              ),
              bottomDescription(
                context,
                'Pumped Hydro Storage',
                'Stores energy by pumping water uphill during low-demand periods and releasing it downhill to generate electricity when demand is high.',
                'Offers large-scale, grid-level energy storage.',
                'assets/energy1.png',
                false,
              ),
              bottomDescription(
                context,
                'Flywheel Energy Storage',
                'Stores energy by spinning a rotor at high speeds and converting kinetic energy into electricity when needed.',
                'Provides fast response times for grid stabilization.',
                'assets/energy1.png',
                true,
              ),
              bottomDescription(
                context,
                'Thermal Energy Storage',
                'Stores heat or cold for later use in heating, cooling, and power generation.',
                'Utilized in buildings, industrial processes, and concentrated solar power plants.',
                'assets/energy1.png',
                false,
              ),
              header(context, 'Benefits of Energy Storage'),
              benefits(
                  context,
                  '1. Grid Stability. Balances supply and demand, reducing the risk of blackouts and brownouts.',
                  '2. Integration of Renewable. Stores excess energy from solar and wind for use when the sun isn\'t shining or the wind isn\'t blowing.',
                  '3. Peak Shaving. Reduces electricity costs by using stored energy during peak demand periods.',
                  '4. Backup Power. Provides emergency power during outages, improving grid resilience.'),
              header(context, 'Applications of Energy Storage'),
              benefits(
                  context,
                  '1. Residential. Backup power for homes, time-of-use electricity cost management.',
                  '2.Commercial/Industrial. Load shifting, peak shaving, uninterruptible power supply (UPS).',
                  '3. Grid-Level. Frequency regulation, renewable energy integration, grid stabilization.',
                  ''),
              header(context, 'Future Trends'),
              benefits(
                context,
                'Battery Technology Advancements.  Increasing energy density and decreasing costs.',
                'Grid-Scale Projects.   Expansion of large-scale energy storage projects to support renewable energy deployment.',
                'Hybrid Systems.   Combining different storage technologies for optimized performance and flexibility.',
                '',
              ),
              header(context, 'How Can you help?'),
              benefits(
                context,
                'Promote Policy. Advocate for policies that incentivize  energy storage deployment.',
                'Invest in Research. Support research and development efforts to improve energy storage technologies.',
                'Adopt Energy Storage. Consider implementing energy storage solutions in your home or business to reduce electricity costs and support grid stability.',
                '',
              ),
              lastDescription(
                context,
                'assets/energy1.png',
                'Promote Policy. Advocate for policies that incentives and energy storage deployment. Promote Policy. Advocate for policies that incentives and energy storage deployment. Promote Policy. Advocate for policies that incentives and energy storage deployment. Promote Policy. Advocate for policies that incentives and energy storage deployment.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
