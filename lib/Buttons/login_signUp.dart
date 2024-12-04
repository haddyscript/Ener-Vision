import 'package:flutter/material.dart';

class PositionedButton extends StatelessWidget {
  final double top;
  final double right;
  final String buttonText;
  final Widget targetPage;

  const PositionedButton({
    Key? key,
    required this.top,
    required this.right,
    required this.buttonText,
    required this.targetPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
          // backgroundColor: const Color(0xFF75FFBA),
          backgroundColor: const Color(0xFF02A676),
          elevation: 5.0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
