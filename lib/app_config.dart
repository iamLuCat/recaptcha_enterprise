import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  final String androidSiteKey;
  final String iosSiteKey;

  const AppConfig({required this.androidSiteKey, required this.iosSiteKey});

  static Future<AppConfig> forEnvironment(String? env) async {
    env = env ?? 'dev';

    final contents = await rootBundle.loadString(
      'assets/config/$env.json',
    );

    final json = jsonDecode(contents);
    return AppConfig(androidSiteKey: json['androidSiteKey'], iosSiteKey: json['iosSiteKey']);
  }
}
