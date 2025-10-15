import 'package:flutter/material.dart';
import 'package:noviindus/models/category_modal.dart';
import 'package:noviindus/services/home_service.dart';

class CategoryProvider with ChangeNotifier {
  final HomeService apiService = HomeService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    // Prevent concurrent fetches
    if (_isLoading) return;

    _isLoading = true;
    _error = null; // Clear previous errors
    notifyListeners();

    try {
      final response = await apiService.fetchCategories();
      _categories = response.categories;
      _error = null; // Clear error on success
    } catch (e) {
      _error = 'Failed to load categories: ${e.toString()}';
      _categories = []; // Clear data on error
      debugPrint("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
