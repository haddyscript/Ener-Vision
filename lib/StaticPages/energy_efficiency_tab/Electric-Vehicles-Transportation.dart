import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/static_page_shared_widgets.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';

import '../../CommonWidgets/appbar-widget.dart';

class ElectricVehicles extends StatelessWidget {
  const ElectricVehicles({super.key, required int selectedIndex});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Electric Vehicles',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              firstParagraph(context,
                  'Electric vehicles(EVs)  are vehicles powered by electricity stored in batteries, offering a cleaner and more sustainable mode of transportation compared to traditional fossil fuel-powered vehicles.'),
              firstParagraph(context,
                  'EVs  convert more energy into propulsion, reducing energy consumption and greenhouse gas emissions, compared to traditional vehicles that waste heat through heat dissipation.'),
              bigImageContainer(context, 'assets/image0.png'),
              header(context, 'Types of Electric Vehicles'),
              bottomDescription(
                context,
                'Battery Electric Vehicles(BEVs)',
                'Operate solely on battery power, producing zero tailpipe emissions.',
                'Recharged by plugging into an electric power source.',
                'assets/energy1.png',
                true,
              ),
              bottomDescription(
                context,
                'Plug-in Hybrid Electric Vehicles(PHEVs)',
                'Combine an internal combustion engine with an electric motor and battery.',
                'Can operate on electric power alone for shorter distances before switching to gasoline.',
                'assets/energy1.png',
                false,
              ),
              header(context, 'Benefits of Electric Vehicles'),
              benefits(
                  context,
                  '1. Reduced Emissions. Lower greenhouse gas emissions compared to conventional vehicles.',
                  '2. Energy Efficiency. Electric motors are more efficient than internal combustion engines.',
                  '3. Cost Savings. Lower fuel and maintenance costs over the vehicle\'s lifetime.',
                  '4. Energy Independence.  Reduces dependence on imported oil and fossil fuels.'),
              header(context, 'Challenges and Considerations'),
              benefits(
                  context,
                  '1. Range Anxiety. Concern about the limited driving range of some EVs.',
                  '2. Charging Infrastructure. Availability of charging stations and charging times.',
                  '3. Initial Cost. Higher upfront cost compared to traditional vehicles, although long-term savings offset this.',
                  ''),
              header(context, 'Future of Transportation'),
              benefits(
                  context,
                  '1. Autonomous Vehicles. Integration of EV technology with self-driving cars.',
                  '2. Smart Grid Integration. EVs as part of a smarter, more efficient energy grid.',
                  '3. Shared Mobility. Electric ride-sharing and car-sharing services.',
                  ''),
              header(context, 'How Can you help?'),
              benefits(
                context,
                'Choose EVs. Consider purchasing or leasing an electric vehicle for your transportation needs.',
                'Advocate for EVs. Support policies and initiatives that promote electric vehicle adoption.',
                'Educate Others. Share information about the benefits of EVs with friends and family.',
                '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
