import 'package:flutter/material.dart';
import 'package:noviindus/models/category_modal.dart';
import 'package:noviindus/models/my_feed_model.dart';
import 'package:noviindus/services/home_service.dart';

class CategoryProvider with ChangeNotifier {
  final HomeService apiService = HomeService();
  List<Category> categories = [];

  Future<void> fetchCategories() async {
    final response = await apiService.fetchCategories();
    categories = response.categories;
    notifyListeners();
  }
}

class MyFeedProvider with ChangeNotifier {
  final HomeService myFeedService = HomeService();
  List<Result> _feedResults = [];
  bool _isLoading = false;

  List<Result> get feeds => _feedResults;
  bool get isLoading => _isLoading;

  Future<void> fetchMyFeed() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await myFeedService.fetchMyFeed();
      _feedResults = response.results;
    } catch (e) {
      debugPrint("Error fetching feed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
