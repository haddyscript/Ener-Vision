import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';
import 'package:supabase_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Render Sign Up Page UI', (WidgetTester tester) async {
    // Render the Sign Up Page
    await tester.pumpWidget(
      MaterialApp(
        home: SignUpPage(),
      ),
    );

    // Add a delay to allow visual inspection in test environments
    await tester.pumpAndSettle();

    // Check if key UI elements are present
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Become a member!'), findsOneWidget);
    expect(find.text('Enter your credentials to continue'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);

    // Debug: Print widget tree to console
    debugPrint(tester.element(find.byType(SignUpPage)).toStringDeep());
  });
}