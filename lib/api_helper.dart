import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static String? _ip;

  static Future<String> getIp() async {
    if (_ip != null) return _ip!;
    final prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('api_ip') ?? '';
    return _ip!;
  }

  static Future<Uri> buildUri(String path, [Map<String, String>? params]) async {
    final ip = await getIp();
    final uri = Uri.parse('http://$ip:5000$path');
    if (params != null) {
      return uri.replace(queryParameters: params);
    }
    return uri;
  }

  // 🔽 IP'yi sıfırlamak için eklendi
  static Future<void> resetIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_ip');
    _ip = null;
  }
}
