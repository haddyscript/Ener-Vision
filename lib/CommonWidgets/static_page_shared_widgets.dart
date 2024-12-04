import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

Widget firstParagraph(BuildContext context, String descriptions,
    {int firstWordsCount = 2}) {
  final firstWords = descriptions.split(' ').take(firstWordsCount).join(' ');
  final restOfTheText = descriptions.split(' ').skip(firstWordsCount).join(' ');
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
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

Widget newFirstParagraph(
    BuildContext context, String descriptions, String applianceName) {
  final parts = descriptions.split(applianceName);
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    child: RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
        children: [
          TextSpan(
            text: parts[0],
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
          ),
          TextSpan(
            text: applianceName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
          ),
          if (parts.length > 1)
            TextSpan(
              text: parts[1],
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 10),
            ),
        ],
      ),
    ),
  );
}

// Kini para sa bold ang first words. Add space if ni sobra ang bold words.
// Or change the number of firsWordsCount.
Widget benefits(BuildContext context, String text1, String text2, String text3,
    String text4) {
  double screenWidth = MediaQuery.of(context).size.width;
  return Container(
    width: screenWidth * 0.8,
    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildRichText(context, text1),
        buildRichText(context, text2),
        buildRichText(context, text3),
        buildRichText(context, text4, firstWordsCount: 7),
      ],
    ),
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

Widget imageContainer(String imagePath) {
  return Image.asset(imagePath);
}

Widget bigImageContainer(BuildContext context, String imagePath) {
  double screenWidth = MediaQuery.of(context).size.width;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Image.asset(
      imagePath,
      width: screenWidth - 40,
      height: 167,
      fit: BoxFit.cover,
    ),
  );
}

Widget title(String title) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(
          color: AppColors.primaryColor,
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
        title ?? 'Appliance Name',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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

Widget header(BuildContext context, String descriptions) {
  return Container(
    height: 30,
    color: const Color(0xFF1BBC9B),
    // color: AppColors.primaryColor.withOpacity(0.7),
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        descriptions,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
      ),
    ),
  );
}

Widget lastDescription(BuildContext context, String imagePath, String text1) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 120,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text1,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10), // Adjusting text style to match theme
            ),
          ),
        )
      ],
    ),
  );
}

Widget bottomDescription(
  BuildContext context,
  String header,
  String text1,
  String text2,
  String imagePath,
  bool isImageOnLeft,
) {
  return Container(
    margin: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImageOnLeft)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(imagePath),
              const SizedBox(width: 100),
            ],
          ),
        if (isImageOnLeft) const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        FontWeight.w600), // Adjusting text style to match theme
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  text1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10), // Adjusting text style to match theme
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  text2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10), // Adjusting text style to match theme
                ),
              ),
            ],
          ),
        ),
        if (!isImageOnLeft) const SizedBox(width: 0),
        if (!isImageOnLeft)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 160,
              ),
            ],
          ),
      ],
    ),
  );
}

PreferredSize _buildAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildBoxDecoration(),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
          ],
        ),
      ),
    ),
  );
}

BoxDecoration _buildBoxDecoration() {
  return const BoxDecoration(
    color: Color(0xFF02A676),
  );
}

Widget _buildTopBar() {
  return Row(
    children: [
      const Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 20.0, right: 5.0),
          child: Row(
            children: [
              Icon(
                Icons.arrow_back,
                size: 30.0,
                color: Colors.white,
              ),
              SizedBox(width: 40.0),
              Text(
                'Energy Efficiency',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSans',
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: CircleAvatar(
          radius: 30,
          backgroundImage: Image.asset(
            'assets/images/profile.jpg',
            width: 50.0,
            height: 50.0,
          ).image,
        ),
      ),
    ],
  );
}
