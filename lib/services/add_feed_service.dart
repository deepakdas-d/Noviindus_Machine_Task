import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noviindus/models/login_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final Dio _dio = Dio();

  Future<void> uploadFeed({
    required File video,
    required File image,
    required String desc,
    required List<int> categoryIds,
    required Function(int sent, int total) onProgress,
  }) async {
    try {
      // Load user token
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData == null) {
        throw Exception('User not logged in');
      }

      final jsonData = jsonDecode(userData);
      final user = LoginResponse.fromJson(jsonData);
      final token = user.accessToken;

      // Create form data
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          video.path,
          filename: video.uri.pathSegments.last,
        ),
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
        'desc': desc,
        'categories': categoryIds,
      });

      // Send request with Bearer token
      final response = await _dio.post(
        '$baseUrl/my_feed',
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('[FeedService] Upload success: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('[FeedService] Upload failed: $e');
      print(stackTrace);
      rethrow;
    }
  }
}
