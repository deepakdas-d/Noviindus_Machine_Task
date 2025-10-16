import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:noviindus/models/category_modal.dart';
import 'package:noviindus/models/home_feed_model.dart';

class HomeService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch list of categories from the API
  Future<CategoryResponse> fetchCategories() async {
    final url = Uri.parse('$baseUrl/category_list');
    log('[HomeService] Fetching categories from: $url');

    try {
      final response = await http.get(url);

      log('[HomeService] Response status: ${response.statusCode}');
      // log('[HomeService] Response body: ${response.body}');

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

  Future<List<HomeFeed>> fetchHomeFeed() async {
    final url = Uri.parse('$baseUrl/home');
    log('Fetching home feed from: $url', name: 'HomeService');

    try {
      final response = await http.get(url);
      log('HTTP Status Code: ${response.statusCode}', name: 'HomeService');
      log('Response body: ${response.body}', name: 'HomeService');

      if (response.statusCode == 202) {
        final data = json.decode(response.body);
        log('Decoded JSON data: $data', name: 'HomeService');

        final List feeds = data['results'] ?? [];
        log('Number of feeds fetched: ${feeds.length}', name: 'HomeService');

        return feeds.map((json) {
          final feed = HomeFeed.fromJson(json);
          log('Parsed feed: ${feed.description}', name: 'HomeService');
          return feed;
        }).toList();
      } else {
        log(
          'Failed to load home feed, status: ${response.statusCode}',
          name: 'HomeService',
        );
        throw Exception('Failed to load home feed');
      }
    } catch (e, stackTrace) {
      log(
        'Error fetching home feed: $e',
        name: 'HomeService',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
