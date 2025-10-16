import 'package:flutter/material.dart';
import 'package:noviindus/models/my_feed_model.dart';
import 'package:noviindus/services/my_feed_service.dart';

class MyFeedProvider extends ChangeNotifier {
  final List<Result> _feeds = [];
  List<Result> get feeds => _feeds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _nextUrl;
  final _service = MyFeedService();

  Future<void> loadInitialFeeds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchMyFeed();
      _feeds
        ..clear()
        ..addAll(response.results);
      _nextUrl = response.next;
    } catch (e) {
      debugPrint('[MyFeedProvider] Error loading feeds: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreFeeds() async {
    if (_isLoadingMore || _nextUrl == null) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _service.fetchMyFeed(url: _nextUrl);
      _feeds.addAll(response.results);
      _nextUrl = response.next;
    } catch (e) {
      debugPrint('[MyFeedProvider] Error loading more: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshFeeds() async {
    await loadInitialFeeds();
  }

  bool get hasMore => _nextUrl != null;
}
