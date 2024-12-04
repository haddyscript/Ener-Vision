import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Define the app's theme
      theme: ThemeData(
        // Set the app's primary theme color
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: OpenDialog(),
    );
  }
}

class OpenDialog extends StatelessWidget {
// Function to show the animated dialog
  void _showAnimatedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedAlertDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animated AlertDialog Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showAnimatedDialog(context);
          },
          child: Text('Show Animated Dialog'),
        ),
      ),
    );
  }
}

class AnimatedAlertDialog extends StatefulWidget {
  @override
  _AnimatedAlertDialogState createState() => _AnimatedAlertDialogState();
}

class _AnimatedAlertDialogState extends State<AnimatedAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start the animation when
    // the dialog is displayed
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          title: Text("Animated Alert Dialog"),
          content: Text("This is an animated AlertDialog."),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                // Reverse the animation
                // and close the dialog
                _controller.reverse();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
// Future<void> main() async {
//   runApp(
//     const MaterialApp(
//       home: CarmelAndAnne(selectedIndex: 1),
//     ),
//   );
// }
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home Screen"),
//       ),
//       body: const Center(
//         child: Text("Welcome to Enervision!"),
//       ),
//     );
//   }
// }
//
// // Example home screen after splash screen
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Flutter Demo',
//         home: Scaffold(
//             appBar: AppBar(),
//             body: Container(
//               child: Row(
//                 children: [
//                   Container(
//                     width: 100,
//                     color: Colors.blue,
//                   ),
//                   Container(
//                     width: 100,
//                     color: Colors.red,
//                   ),
//                   Container(
//                     width: 100,
//                     color: Colors.purpleAccent,
//                   ),
//                   Positioned(
//                     child: Container(
//                       width: 100,
//                       height: 100,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             )));
//   }
// }
