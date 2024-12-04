import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class SnackBarHelper {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// import 'package:fluttertoast/fluttertoast.dart';
//
// Fluttertoast.showToast(
// msg: "Email is not available",
// toastLength: Toast.LENGTH_SHORT,
// gravity: ToastGravity.BOTTOM,
// timeInSecForIosWeb: 1,
// backgroundColor: Colors.red,
// textColor: Colors.white,
// fontSize: 16.0
// );
Future<void> _showEmailErrorDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Registration Error'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('The email is already registered.'),
              Text('Please use a different email.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
