import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/users.dart';

class AuthService {

  static const String baseUrl = "http://localhost:3000";

  static Future<User?> login(String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    final data = jsonDecode(response.body);

    if (data["success"]) {
      return User.fromJson(data["user"]);
    } else {
      return null;
    }
  }
}