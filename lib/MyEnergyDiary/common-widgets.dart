import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../CommonWidgets/box_decorations.dart';

class HomeUsage extends StatelessWidget {
  final String kwh;

  const HomeUsage({super.key, required this.kwh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 208,
      width: 202,
      decoration: greyBoxDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.house_siding_rounded,
            size: 150,
          ),
          Text(
            kwh,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Home Usage',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class NumberOfAppliances extends StatelessWidget {
  const NumberOfAppliances({super.key});

  @override
  Widget build(BuildContext context) {
    int numberOfAppliances = 10;

    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image (7).png',
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                "$numberOfAppliances",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "No. of Appliances Added",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EstimatedCostPerMonth extends StatelessWidget {
  const EstimatedCostPerMonth({super.key});

  @override
  Widget build(BuildContext context) {
    int numberOfAppliances = 10;

    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image (9).png',
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                "$numberOfAppliances",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Estimated Cost for the Month",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PeakUsageTime extends StatelessWidget {
  const PeakUsageTime({super.key});

  @override
  Widget build(BuildContext context) {
    int numberOfAppliances = 10;

    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image (8).png',
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                "$numberOfAppliances",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Peak Usage Time",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApplianceInfoCard extends StatelessWidget {
  final String imagePath;
  final String mainText;
  final String subText;

  const ApplianceInfoCard({
    super.key,
    required this.imagePath,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(), // Assuming this is defined elsewhere
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                mainText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
