import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendy_mobile/config/api_config.dart';

class AuthService {
  final baseUrl = ApiConfig.baseUrl;// para dispositivo físico, usar IP da máquina na rede local

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return true;
    }

    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    }

    await prefs.remove("token");
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}
