import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/static_page_shared_widgets.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';

import '../../CommonWidgets/appbar-widget.dart';

class Carmel extends StatelessWidget {
  const Carmel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
        appBar: customAppBar1(
          title: 'All Devices',
          showBackArrow: true,
          showProfile: true,
          showTitle: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: content(context),
      ),
    );
  }

  Widget content(BuildContext context) {
    return Column(
      children: [
        title("LG Smart Inverter RVSB243PZ"),
        smallerImageContainer(context, 'assets/refrigerator.png'),
        keyFeatures(context)
      ],
    );
  }

  Widget smallerImageContainer(BuildContext context, String imagePath) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        imagePath,
        width: screenWidth - 30,
        height: 120,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget title(String title) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1BBC9B),
            offset: Offset(1.0, 1.0),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      height: 30,
      child: Center(
        child: Text(
          title ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget keyFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRichText(context, 'Key Features:', firstWordsCount: 2),
        bulletList(context, [
          'Linear Cooling™',
          'Smart Inverter Compressor',
          'Soft LED Lighting',
          'Fresh Zone',
          'Spaceplus Ice System',
          'Express Cool',
          'Express Freeze',
        ]),
        buildRichText(context, 'Energy Star Certified: No', firstWordsCount: 2),
        buildRichText(context, 'Available Stores: Shopee', firstWordsCount: 2),
        buildRichText(context, 'Type: Freezing Refrigerator',
            firstWordsCount: 1),
      ],
    );
  }

  Widget bulletList(BuildContext context, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CarmelAndAnne extends StatelessWidget {
  const CarmelAndAnne({super.key, required int selectedIndex});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
        appBar: customAppBar1(
          title: 'All Devices',
          showBackArrow: true,
          showProfile: true,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              title("LG Smart Inverter RVSB243PZ"),
              smallerImageContainer(context, 'assets/refrigerator.png'),
              header(context, 'Types of Electric Vehicles'),
              newFirstParagraph(
                context,
                'This Kaisa Villa Freezing Refrigerator is a compact two-door fridge perfect for singles or small households.',
                'Kaisa Villa Freezing Refrigerator',
              ),
              newFirstParagraph(
                context,
                'This "LG Smart Inverter Side by Side Refrigerator RVSB243PZ" features Linear Cooling™ technology for consistent temperature, a Smart Inverter Compressor for energy efficiency, and a sleek design with LED lighting.',
                'LG Smart Inverter Side by Side Refrigerator RVSB243PZ',
              ),
              header(context, 'Device Information'),
              deviceInformation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget deviceInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRichText(context, 'Price: 72,999.00', firstWordsCount: 1),
        buildRichText(context, 'Powered by: LG', firstWordsCount: 1),
        buildRichText(context,
            'Dimensions: 18.4 inches (46.4 cm) x 13.4 inches (33.8 cm) x 9.1 inches (23.4 cm)',
            firstWordsCount: 1),
        buildRichText(context, 'Weight: 30.5 lbs (14.5 kg)'),
        buildRichText(context, 'Voltage: 120V'),
        buildRichText(context, 'Current: 10A'),
        buildRichText(context, 'Warranty: 2 years'),
        buildRichText(context, 'Key Features: \n  2 years'),
      ],
    );
  }

  Widget buildRichText(BuildContext context, String text,
      {int firstWordsCount = 3}) {
    final firstWords = text.split(' ').take(firstWordsCount).join(' ');
    final restOfTheText = text.split(' ').skip(firstWordsCount).join(' ');

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
          children: [
            TextSpan(
              text: firstWords,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
            ),
            TextSpan(
              text: restOfTheText,
            ),
          ],
        ),
      ),
    );
  }
}
