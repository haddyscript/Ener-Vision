import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

AppBar customAppBar1({
  String? title,
  VoidCallback? onBackPressed,
  bool showBackArrow = true,
  bool showTitle = true,
  bool showProfile = true,
  String? profileImage, // This should now be a URL
}) {
  return AppBar(
    toolbarHeight: 89,
    backgroundColor: Colors.white,
    leading: showBackArrow
        ? Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 35,
                color: AppColors.primaryColor,
              ),
              onPressed: onBackPressed ?? () {},
            ),
          )
        : null,
    actions: showProfile
        ? [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundImage:
                    (profileImage != null && profileImage.isNotEmpty)
                        ? NetworkImage(profileImage!)
                        : const AssetImage('assets/profile2.jpg')
                            as ImageProvider, // Default image
              ),
            ),
          ]
        : [],
    title: showTitle
        ? Container(
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryColor,
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
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          )
        : null,
    centerTitle: true,
  );
}

AppBar customAppBar3({
  String? title,
  VoidCallback? onBackPressed,
  bool showBackArrow = true,
  bool showTitle = true,
  bool showProfile = true,
  String? profileImage,
}) {
  return AppBar(
    toolbarHeight: 89,
    backgroundColor: Color(0xFF1BBC9B),
    leading: showBackArrow
        ? Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 35,
                color: Colors.white,
              ),
              onPressed: onBackPressed ?? () {},
            ),
          )
        : null,
    actions: showProfile
        ? [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage)
                    : AssetImage('assets/profile (2).png') as ImageProvider,
              ),
            ),
          ]
        : [],
    title: showTitle
        ? Container(
            child: Center(
              child: Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : null,
    centerTitle: true,
  );
}

Widget _buildTabItem({
  required String title,
  required int index,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1BBC9B) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected
              ? Border.all(color: const Color(0xFFADE7DB), width: 2.0)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black, fontFamily: ''),
        ),
      ),
    ),
  );
}

AppBar customAppBar4({
  String? title,
  VoidCallback? onBackPressed,
  bool showBackArrow = true,
  bool showTitle = true,
  bool showProfile = true,
  String? profileImage,
}) {
  return AppBar(
    toolbarHeight: 89,
    backgroundColor: Colors.white,
    leading: showBackArrow
        ? Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 35,
                color: AppColors.primaryColor,
              ),
              onPressed: onBackPressed ?? () {},
            ),
          )
        : null,
    actions: showProfile
        ? [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundImage:
                    (profileImage != null && profileImage.isNotEmpty)
                        ? NetworkImage(profileImage!)
                        : const AssetImage('assets/profile (2).png')
                            as ImageProvider, // Default image
              ),
            ),
          ]
        : [],
  );
}

// AppBar customAppBar({
//   String? title,
//   VoidCallback? onBackPressed,
//   bool showBackArrow = true,
//   bool showTitle = true,
//   bool showProfile = true,
//   String? profileImage, // Make profileImage required
// }) {
//   return AppBar(
//     toolbarHeight: 89,
//     backgroundColor: Colors.white,
//     leading: showBackArrow
//         ? Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back,
//                 size: 35,
//                 color: AppColors.primaryColor,
//               ),
//               onPressed: onBackPressed ?? () {},
//             ),
//           )
//         : null,
//     actions: showProfile
//         ? [
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: CircleAvatar(
//                 backgroundImage: profileImage != null
//                     ? NetworkImage(profileImage)
//                     : AssetImage('assets/profile (2).png') as ImageProvider,
//               ),
//             ),
//           ]
//         : [],
//     title: showTitle
//         ? Container(
//             width: 250,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: const [
//                 BoxShadow(
//                   color: AppColors.primaryColor,
//                   offset: Offset(1.0, 1.0),
//                   blurRadius: 5.0,
//                   spreadRadius: 1.0,
//                 ),
//                 BoxShadow(
//                   color: Colors.white,
//                   offset: Offset(0.0, 0.0),
//                   blurRadius: 0.0,
//                   spreadRadius: 0.0,
//                 ),
//               ],
//             ),
//             height: 30,
//             child: Center(
//               child: Text(
//                 title ?? '',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           )
//         : null,
//     centerTitle: true,
//   );
// }
