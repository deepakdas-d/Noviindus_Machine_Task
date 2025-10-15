class LoginResponse {
  final bool status;
  final bool privilage;
  final String phone;
  final String refreshToken;
  final String accessToken;

  LoginResponse({
    required this.status,
    required this.privilage,
    required this.phone,
    required this.refreshToken,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      privilage: json['privilage'] ?? false,
      phone: json['phone'] ?? '',
      refreshToken: json['token']?['refresh'] ?? '',
      accessToken: json['token']?['access'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'privilage': privilage,
    'phone': phone,
    'token': {'refresh': refreshToken, 'access': accessToken},
  };
}
