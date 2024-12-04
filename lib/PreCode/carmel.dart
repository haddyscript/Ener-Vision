import 'package:flutter/material.dart';

Widget headers(BuildContext context, String descriptions) {
  return Container(
    height: 30,
    color: const Color(0xFF1BBC9B),
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        descriptions,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
      ),
    ),
  );
}

class Carmel extends StatelessWidget {
  const Carmel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: content(context),
      ),
    );
  }

  Widget content(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title("Kaisa Villa Freezing Refrigerator"),
          smallerImageContainer(context, 'assets/images/ref.png'),
          headers(context, 'DESCRIPTION'),
          newFirstParagraph(
            context,
            'This Kaisa Villa Freezing Refrigerator is a compact two-door fridge perfect for singles or small households.',
            'Kaisa Villa Freezing Refrigerator',
          ),
          headers(context, 'DEVICE INFORMATION'),
          keyFeatures(context),
          headers(context, 'ENERGY EFFICIENCY DETAILS'),
          energyEfficiencyDetails(context),
          headers(context, 'USAGE AND ENVIRONMENTAL IMPACT'),
          usage(context),
        ],
      ),
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
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1BBC9B),
            spreadRadius: 2,
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
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget newFirstParagraph(
      BuildContext context, String descriptions, String applianceName) {
    final parts = descriptions.split(applianceName);
    if (parts.isEmpty) {
      return Text(descriptions);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
          children: [
            TextSpan(
              text: parts[0],
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
            ),
            TextSpan(
              text: applianceName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
            ),
            if (parts.length > 1)
              TextSpan(
                text: parts[1],
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget keyFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRichText(context, 'Price: ₱2,799.00', firstWordsCount: 1),
        buildRichText(context, 'Capacity: 48L (16L freezing capacity)',
            firstWordsCount: 1),
        buildRichText(context, 'Material: Polypropylene (PP)',
            firstWordsCount: 1),
        buildRichText(context, 'Key Features:', firstWordsCount: 2),
        bulletList(context, [
          'Energy-saving',
          'Frost-free design',
          'Low noise level',
        ]),
        buildRichText(context, 'Energy Star Certified: No', firstWordsCount: 3),
        buildRichText(context, 'Available Stores: Shopee', firstWordsCount: 2),
        buildRichText(context, 'Type: Freezing Refrigerator',
            firstWordsCount: 1),
      ],
    );
  }

  Widget energyEfficiencyDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRichText(context, 'Power Consumption: 120W - 220V',
            firstWordsCount: 2),
        buildRichText(context, 'Estimated Cost per Hour: ₱1.32',
            firstWordsCount: 3),
        buildRichText(
            context, 'Estimated Daily Cost: ₱18.48 (assuming 24 hours of use)',
            firstWordsCount: 3),
        buildRichText(context, 'Estimated Monthly Cost: ₱554.4',
            firstWordsCount: 3),
      ],
    );
  }

  Widget usage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRichText(context, 'Typical Usage: 24 hours per day',
            firstWordsCount: 2),
        buildRichText(context,
            'CO2 Emissions: 1.176 kg per day (based on average emissions factor)',
            firstWordsCount: 2),
        buildRichText(context, 'Energy Saving Tips:', firstWordsCount: 3),
        bulletList(context, [
          'Keep the door closed as much as possible to maintain temperature and reduce energy consumption.',
        ]),
      ],
    );
  }
}

Widget buildRichText(BuildContext context, String text,
    {int firstWordsCount = 3}) {
  final firstWords = text.split(' ').take(firstWordsCount).join(' ');
  final restOfTheText = text.split(' ').skip(firstWordsCount).join(' ');
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
        children: [
          TextSpan(
            text: firstWords,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
          ),
          TextSpan(
            text: restOfTheText,
          ),
        ],
      ),
    ),
  );
}

Widget bulletList(BuildContext context, List<String> items) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
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
                      ?.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}
