import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';

class CommunityGuidelines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1BBC9B), // Setting the primary color
        scaffoldBackgroundColor: Colors.white, // White background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black), // Black text for large body
          bodyMedium: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black), // Black text for medium body
          bodySmall: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black), // Black text for small body
        ),
      ),
      home: CommunityHomePage(),
    );
  }
}

class CommunityHomePage extends StatefulWidget {
  @override
  _CommunityHomePageState createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage> {
  bool _hasAcknowledged = false;
  bool _isPostingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // appBar: AppBar(
      //   title: const Text(
      //     'Community',
      //     style: TextStyle(fontFamily: 'Montserrat'),
      //   ),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: Icon(Icons.close), // X icon
      //   //     onPressed: () {
      //   //       Navigator.of(context).pop();
      //   //     },
      //   //   ),
      //   // ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Community Guidelines',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 16.0),
            Text(
              '''Welcome to our community! Here are some guidelines you should follow when posting and interacting with others:''',
              style: Theme.of(context).textTheme.bodyMedium, // Using bodyMedium
            ),
            const SizedBox(height: 16.0),
            _description(context, descriptions),
            const SizedBox(height: 24.0),
            CheckboxListTile(
              title: const Text(
                  "I acknowledge and agree to follow the Community Guidelines",
                  style: TextStyle(fontFamily: 'Montserrat')),
              value: _hasAcknowledged,
              onChanged: (bool? value) {
                setState(() {
                  _hasAcknowledged = value ?? false;
                  _isPostingEnabled = _hasAcknowledged;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF1BBC9B), // Change color when checked
              checkColor: Colors.white, // Checkmark color
              tileColor: Colors.white, // Background color remains white
            ),
            const SizedBox(height: 16.0),
            Center(
              // Centering the button
              child: ElevatedButton(
                onPressed: _isPostingEnabled
                    ? () {
                        print("Proceeding to post...");
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBC9B), // Button color
                ),
                child: const Text(
                  "Continue to Post",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat'), // White text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _description(BuildContext context, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0), // spacing between sections
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[700]),
              ),
              const SizedBox(height: 4.0),
              ..._buildDescriptionList(item['description']
                  as List<String>), // Handle multiple bullet points
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildDescriptionList(List<String> descriptions) {
    return descriptions.map((desc) {
      return Padding(
        padding: const EdgeInsets.only(
            left: 20.0, top: 4.0), // 20 px indentation for bullet points
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ",
                style: TextStyle(fontSize: 16)), // Bullet point symbol
            Expanded(
              child: Text(
                desc,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
