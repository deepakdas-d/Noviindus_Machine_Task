import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:noviindus/models/category_modal.dart';
import 'package:noviindus/models/login_modal.dart';
import 'package:noviindus/models/my_feed_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch list of categories from the API
  Future<CategoryResponse> fetchCategories() async {
    final url = Uri.parse('$baseUrl/category_list');
    log('[HomeService] Fetching categories from: $url');

    try {
      final response = await http.get(url);

      log('[HomeService] Response status: ${response.statusCode}');
      log('[HomeService] Response body: ${response.body}');

      if (response.statusCode == 202) {
        final data = json.decode(response.body);
        log('[HomeService] Successfully parsed category response.');
        return CategoryResponse.fromJson(data);
      } else {
        log(
          '[HomeService] Failed to load categories. Status: ${response.statusCode}',
        );
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log(
        '[HomeService] Exception occurred while fetching categories: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  //feed api service
  Future<MyFeedResponse> fetchMyFeed() async {
    final url = Uri.parse('$baseUrl/my_feed');
    log('[MyFeedService] 🌐 Fetching my feed from: $url');

    try {
      // 🔹 Load user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData == null) {
        log('[MyFeedService] ❌ No user data found.');
        throw Exception('User not logged in. Please log in again.');
      }

      // 🔹 Decode and extract access token
      final jsonData = jsonDecode(userData);
      final user = LoginResponse.fromJson(jsonData);
      final token = user.accessToken;

      if (token.isEmpty) {
        log('[MyFeedService] ❌ Access token missing.');
        throw Exception('Access token missing. Please log in again.');
      }

      log(
        '[MyFeedService] ✅ Using token (first 10 chars): ${token.substring(0, 10)}...',
      );

      // 🔹 API call with Authorization header
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      log('[MyFeedService] 📡 Response status: ${response.statusCode}');
      log('[MyFeedService] 📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('[MyFeedService] ✅ Feed fetched successfully.');
        return MyFeedResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        log('[MyFeedService] ⚠️ Unauthorized: Token expired or invalid.');
        throw Exception('Session expired. Please log in again.');
      } else {
        log('[MyFeedService] ❌ Failed to load feed: ${response.statusCode}');
        throw Exception(
          'Failed to load feed. Server responded with ${response.statusCode}.',
        );
      }
    } catch (e, stackTrace) {
      log(
        '[MyFeedService] ❌ Exception while fetching feed: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
