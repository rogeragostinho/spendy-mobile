import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendy_mobile/config/api_config.dart';

class ExpenseService {
  final baseUrl = ApiConfig.baseUrl;

  Future<List<dynamic>> getExpenses(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Utilizador não autenticado");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/groups/$groupId/expenses"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["expenses"];
    }

    throw Exception("Erro ao carregar despesas");
  }

  Future<Map<String, dynamic>> createExpense({
    required int groupId,
    required String description,
    required double amount,
    required List<int> memberIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Utilizador não autenticado");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/expenses"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "group_id": groupId,
        "description": description,
        "amount": amount,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erro ao criar despesa");
    }

    return jsonDecode(response.body);
  }
}
