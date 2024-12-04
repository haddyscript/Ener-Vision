import 'package:flutter/material.dart';

//Kani carms ilisi lang ni ug asa nakabutang imong textfield na code
import '../CommonWidgets/textfield.dart';

class SuggestionExample extends StatefulWidget {
  @override
  State<SuggestionExample> createState() => _SuggestionExampleState();
}

class _SuggestionExampleState extends State<SuggestionExample> {
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: MyTextField(
          controller: _passwordController,
          obscureText: true,
          hintText: 'Password',
          prefixIcon: Icons.lock_open_outlined,
          onChanged: (value) {
            // user.password = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter Password';
            } else {
              return null;
            }
          },
          placeholderText: "Passw0rd!",
        ),
      ),
    );
  }
}
