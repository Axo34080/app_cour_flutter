import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract final class Api {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000'; // iOS simulator
  }

  static Map<String, String> authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
