class User {
  final int id;
  final String name;
  final String? image;

  User({required this.id, required this.name, this.image});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], image: json['image']);
  }
}

class HomeFeed {
  final String description;
  final String image;
  final String video;
  final User user;

  HomeFeed({
    required this.description,
    required this.image,
    required this.video,
    required this.user,
  });

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    return HomeFeed(
      description: json['description'],
      image: json['image'],
      video: json['video'],
      user: User.fromJson(json['user']),
    );
  }
}
