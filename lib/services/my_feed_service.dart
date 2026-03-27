import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:noviindus/models/my_feed_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noviindus/models/login_modal.dart';

class MyFeedService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<MyFeedResponse> fetchMyFeed({String? url}) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData == null) throw Exception('User not logged in');

    final jsonData = jsonDecode(userData);
    final token = LoginResponse.fromJson(jsonData).accessToken;

    final uri = Uri.parse(url ?? '$baseUrl/my_feed');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MyFeedResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch feed: ${response.statusCode}');
    }
  }
}
