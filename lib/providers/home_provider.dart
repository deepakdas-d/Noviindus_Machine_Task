import 'package:flutter/material.dart';
import 'package:noviindus/models/home_feed_model.dart';
import 'package:noviindus/services/home_service.dart';

class HomeProvider with ChangeNotifier {
  final HomeService _service = HomeService();
  List<HomeFeed> _feeds = [];
  bool _isLoading = false;
  String? _error;

  List<HomeFeed> get feeds => _feeds;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchFeeds() async {
    _isLoading = true;
    _error = null; // Clear previous errors
    notifyListeners();

    try {
      _feeds = await _service.fetchHomeFeed();
      _error = null; // Clear error on success
    } catch (e) {
      _error = 'Failed to load feeds:';
      _feeds = []; // Clear data on error
      debugPrint('Error fetching home feeds: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
