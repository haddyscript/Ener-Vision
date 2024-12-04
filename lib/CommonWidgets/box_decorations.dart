import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../ConstantTexts/Theme.dart';

BoxDecoration reusableBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFFADE7DB),
        // color: AppColors.secondaryColor,
        offset: Offset(
          4,
          0,
        ),
        blurRadius: 4.0,
        spreadRadius: 4.0,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}

BoxDecoration greyBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    boxShadow: const [
      BoxShadow(
        color: Colors.grey,
        // color: AppColors.primaryColor,
        offset: Offset(
          0,
          0,
        ),
        blurRadius: 10.0,
        spreadRadius: 2.0,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}
