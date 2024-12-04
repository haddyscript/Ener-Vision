import 'dart:io' as io;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Check if the app is running in production mode
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      // Production URL
      return 'https://enervision-3em3.onrender.com';
    }

    // Development URLs
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
      return 'http://10.0.2.2:8080'; // For local development on Android/iOS
    }

    // Default fallback for other platforms
    debugPrint('Unknown platform detected, falling back to localhost.');
    return 'http://localhost:8080';
  }
}
