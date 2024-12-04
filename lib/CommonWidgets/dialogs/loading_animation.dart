import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final Color color;
  final double size;
  final double textSize;

  const LoadingWidget({
    Key? key,
    this.message = 'Loading...',
    this.color = AppColors.primaryColor,
    this.size = 45.0,
    this.textSize = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 500,
        width: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: color,
              size: size,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w500,
                color: color,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
