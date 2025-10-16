class MyFeedResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Result> results;

  MyFeedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory MyFeedResponse.fromJson(Map<String, dynamic> json) {
    return MyFeedResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => Result.fromJson(item))
          .toList(),
    );
  }
}

class Result {
  final int id;
  final String description;
  final String image;
  final String video;
  final List<dynamic> likes;
  final List<dynamic> dislikes;
  final List<dynamic> bookmarks;
  final List<dynamic> hide;
  final String createdAt;
  final bool follow;
  final User user;

  Result({
    required this.id,
    required this.description,
    required this.image,
    required this.video,
    required this.likes,
    required this.dislikes,
    required this.bookmarks,
    required this.hide,
    required this.createdAt,
    required this.follow,
    required this.user,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'],
      description: json['description'],
      image: json['image'],
      video: json['video'],
      likes: json['likes'] ?? [],
      dislikes: json['dislikes'] ?? [],
      bookmarks: json['bookmarks'] ?? [],
      hide: json['hide'] ?? [],
      createdAt: json['created_at'],
      follow: json['follow'] ?? false,
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String? name;
  final String? image;

  User({required this.id, this.name, this.image});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], image: json['image']);
  }
}
