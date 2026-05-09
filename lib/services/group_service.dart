import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendy_mobile/config/api_config.dart';


class GroupService {
  final baseUrl = ApiConfig.baseUrl;

  Future<List<dynamic>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Utilizador não autenticado");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/groups"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["groups"];
    }

    throw Exception("Erro ao carregar grupos");
  }

  Future<List<dynamic>> getMembers(int groupId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
    throw Exception("Utilizador não autenticado");
  }

  final response = await http.get(
    Uri.parse("$baseUrl/groups/$groupId"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["members"];
  }

  throw Exception("Erro ao carregar membros");
}
}
