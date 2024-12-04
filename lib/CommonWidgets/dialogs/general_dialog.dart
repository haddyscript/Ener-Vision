import 'package:flutter/material.dart';

Future<Object?> showCustomGeneralDialog({
  required BuildContext context,
  required Widget pageBuilder,
  bool barrierDismissible = false,
  Color barrierColor = const Color(0x80000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
  Curve transitionCurve = Curves.easeInOut,
}) async {
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    transitionBuilder: (context, animation1, animation2, child) {
      return Transform.scale(
        scale: animation1.value,
        child: Opacity(
          opacity: animation1.value,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation1, animation2) {
      return pageBuilder;
    },
  );
}
