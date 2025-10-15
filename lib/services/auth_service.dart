import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:noviindus/models/login_modal.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<LoginResponse?> verifyOtp(String countryCode, String phone) async {
    log("$baseUrl/otp_verified");
    final url = Uri.parse('$baseUrl/otp_verified');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = json.encode({"phone": phone, "country_code": countryCode});

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 202) {
      return LoginResponse.fromJson(json.decode(responseBody));
    } else {
      // Throw an exception with status code and message
      throw HttpException(
        message: json.decode(responseBody)['message'] ?? response.reasonPhrase,
        code: response.statusCode,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int code;
  HttpException({required this.message, required this.code});

  @override
  String toString() => 'HttpException($code): $message';
}
