import 'package:flutter/foundation.dart';

class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String venueId) => _favoriteIds.contains(venueId);

  void toggle(String venueId) {
    if (_favoriteIds.contains(venueId)) {
      _favoriteIds.remove(venueId);
    } else {
      _favoriteIds.add(venueId);
    }
    notifyListeners();
  }

  void add(String venueId) {
    if (_favoriteIds.add(venueId)) notifyListeners();
  }

  void remove(String venueId) {
    if (_favoriteIds.remove(venueId)) notifyListeners();
  }
}