import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user favorite dishes and recently viewed items across the entire application.
/// Provides real-time reactive notifications to all UI cards and the recommendation engine.
class FavoritesService extends ChangeNotifier {
  FavoritesService._() {
    _loadFromPrefs();
  }

  static final FavoritesService instance = FavoritesService._();

  static const String _keyFavorites = 'user_favorite_dish_ids_set';
  static const String _keyRecentlyViewed = 'user_recently_viewed_dish_ids_list';

  final Set<String> _favoriteIds = {};
  final List<String> _recentlyViewedIds = [];

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  List<String> get recentlyViewedIds => List.unmodifiable(_recentlyViewedIds);

  bool isFavorite(String dishId) => _favoriteIds.contains(dishId);

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_keyFavorites);
      if (favList != null) {
        _favoriteIds.addAll(favList);
      }
      final viewedList = prefs.getStringList(_keyRecentlyViewed);
      if (viewedList != null) {
        _recentlyViewedIds.addAll(viewedList);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('FavoritesService load error: $e');
    }
  }

  Future<bool> toggleFavorite(String dishId) async {
    final willBeFavorite = !_favoriteIds.contains(dishId);
    if (willBeFavorite) {
      _favoriteIds.add(dishId);
    } else {
      _favoriteIds.remove(dishId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyFavorites, _favoriteIds.toList());
    } catch (e) {
      debugPrint('FavoritesService save error: $e');
    }
    return willBeFavorite;
  }

  Future<void> trackViewed(String dishId) async {
    _recentlyViewedIds.remove(dishId);
    _recentlyViewedIds.insert(0, dishId);
    if (_recentlyViewedIds.length > 30) {
      _recentlyViewedIds.removeLast();
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyRecentlyViewed, _recentlyViewedIds);
    } catch (e) {
      debugPrint('FavoritesService trackViewed error: $e');
    }
  }
}

