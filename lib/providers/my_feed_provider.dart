import 'package:flutter/material.dart';
import 'package:noviindus/models/my_feed_model.dart';
import 'package:noviindus/services/my_feed_service.dart';

class MyFeedProvider extends ChangeNotifier {
  final List<Result> _allFeeds = [];
  final List<Result> _displayedFeeds = [];
  List<Result> get feeds => _displayedFeeds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _nextIndex = 0;
  final int _pageSize = 5;

  Future<void> loadInitialFeeds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final feedService = MyFeedService();
      final response = await feedService.fetchMyFeed(); // List<Result>
      _allFeeds.clear();
      _allFeeds.addAll(response); // now response should be List<Result>
      _displayedFeeds.clear();
      _nextIndex = 0;
      _loadMoreChunk();
    } catch (e) {
      debugPrint('[MyFeedProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMore() {
    if (_isLoading) return;
    _loadMoreChunk();
  }

  void _loadMoreChunk() {
    final end = (_nextIndex + _pageSize).clamp(0, _allFeeds.length);
    if (_nextIndex >= _allFeeds.length) return;

    _displayedFeeds.addAll(_allFeeds.getRange(_nextIndex, end));
    _nextIndex = end;
    notifyListeners();
  }

  bool get hasMore => _nextIndex < _allFeeds.length;

  void reset() {
    _allFeeds.clear();
    _displayedFeeds.clear();
    _nextIndex = 0;
    notifyListeners();
  }
}
