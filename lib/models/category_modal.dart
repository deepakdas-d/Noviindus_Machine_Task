class Category {
  final int id;
  final String title;
  final String image;
  bool isSelected;

  Category({
    required this.id,
    required this.title,
    required this.image,
    this.isSelected = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], title: json['title'], image: json['image']);
  }
}

class CategoryResponse {
  final List<Category> categories;
  final bool status;

  CategoryResponse({required this.categories, required this.status});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      categories: (json['categories'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
      status: json['status'],
    );
  }
}
