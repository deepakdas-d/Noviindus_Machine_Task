import 'dart:io';
import 'package:flutter/material.dart';
import '../services/add_feed_service.dart';
import '../services/home_service.dart';
import '../models/category_modal.dart';

class FeedProvider extends ChangeNotifier {
  final FeedService _feedService = FeedService();
  final HomeService _homeService = HomeService();

  List<Category> categories = [];
  File? selectedVideo;
  File? selectedImage;
  String desc = '';
  double uploadProgress = 0;
  bool isLoading = false;

  /// Load categories from API
  Future<void> loadCategories() async {
    try {
      final response = await _homeService.fetchCategories();
      categories = response.categories.map((c) {
        c.isSelected = false;
        return c;
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint(' Opps loading categories: $e');
    }
  }

  void removeVideo() {
    selectedVideo = null;
    notifyListeners();
  }

  void removeImage() {
    selectedImage = null;
    notifyListeners();
  }

  void reset() {
    selectedVideo = null;
    selectedImage = null;
    desc = '';
    uploadProgress = 0.0;
    for (var cat in categories) {
      cat.isSelected = false;
    }
    notifyListeners();
  }

  /// Toggle category selection
  void toggleCategory(Category cat) {
    cat.isSelected = !cat.isSelected;
    notifyListeners();
  }

  /// Setters
  void setVideo(File video) {
    selectedVideo = video;
    notifyListeners();
  }

  void setImage(File image) {
    selectedImage = image;
    notifyListeners();
  }

  void setDesc(String text) {
    desc = text;
  }

  /// Submit feed upload
  Future<void> submitFeed() async {
    if (selectedVideo == null ||
        selectedImage == null ||
        desc.trim().isEmpty ||
        categories.where((c) => c.isSelected).isEmpty) {
      throw Exception('All fields are mandatory');
    }

    isLoading = true;
    uploadProgress = 0;
    notifyListeners();

    try {
      await _feedService.uploadFeed(
        video: selectedVideo!,
        image: selectedImage!,
        desc: desc.trim(),
        categoryIds: categories
            .where((c) => c.isSelected)
            .map((c) => c.id)
            .toList(),
        onProgress: (sent, total) {
          uploadProgress = sent / total;
          notifyListeners();
        },
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
