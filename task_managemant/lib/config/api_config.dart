import 'package:flutter/foundation.dart';

/// API base URL - auto-detects platform for emulator/device.
/// Port 3000 used (Chrome blocks 6000 with ERR_UNSAFE_PORT)
/// Physical device: flutter run --dart-define=API_BASE_URL=http://YOUR_IP:3000/api
class ApiConfig {
  static const int _port = 3000;

  static String get baseUrl {
    const envUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:$_port/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_port/api';
    }
    return 'http://localhost:$_port/api';
  }
}
