import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/dish.dart';
import '../models/meal_plan.dart';
import 'favorites_service.dart';

enum SuggestionTag {
  favoriteFit,
  calorieMatch,
  newDiscovery,
  highProtein,
  lightBite,
}

class SmartSuggestion {
  const SmartSuggestion({
    required this.dish,
    required this.tag,
    required this.tagLabel,
    required this.tagColor,
    required this.reasonDescription,
  });

  final Dish dish;
  final SuggestionTag tag;
  final String tagLabel;
  final Color tagColor;
  final String reasonDescription;
}

/// Intelligent, calorie-aware recommendation engine that dynamically adapts to:
/// 1. Daily remaining calorie budget & meal slots
/// 2. User's favorited dishes (heart clicks) with rotation so favorites don't repeat monotonously
/// 3. Recently visited / browsed food affinity
/// 4. Day-of-week rotation (ensuring suggestions change daily)
/// 5. Fresh discoveries that the user hasn't tried yet
class SmartRecommendationService {
  SmartRecommendationService._();
  static final SmartRecommendationService instance =
      SmartRecommendationService._();

  /// Returns a diverse, master list of all available catalog dishes
  List<Dish> get allDishes {
    final Map<String, Dish> map = {};
    for (final d in [
      ...MockData.dishes,
      ...MockData.frequentOrders,
      ...MockData.combinationBreakfast,
      ...MockData.recommendedBreakfast,
      ...MockData.chickenDishes,
      ...MockData.biriyaniDishes,
      ...MockData.fishDishes,
      ...MockData.vegDishes,
      ...MockData.eggDishes,
      ...MockData.mealsDishes,
      ...MockData.vegRiceDishes,
      MockData.meals,
      MockData.freshJuiceOrange,
      MockData.plainDosa,
      MockData.kuzhipaniyaram,
    ]) {
      map[d.id] = d;
    }
    return map.values.toList();
  }

  /// Generates 4 to 6 curated, calorie-bounded food suggestions.
  List<SmartSuggestion> getSuggestionsForDay({
    required int targetDailyKcal,
    required int plannedTodayKcal,
    int dayOffset = 0,
    MealType? preferredSlot,
  }) {
    final remainingKcal = targetDailyKcal - plannedTodayKcal;
    final favIds = FavoritesService.instance.favoriteIds;
    final viewedIds = FavoritesService.instance.recentlyViewedIds;
    final catalog = allDishes;

    // Use day offset and day of year for deterministic, daily-rotating diversity
    final now = DateTime.now().add(Duration(days: dayOffset));
    final daySeed = now.year * 1000 + now.month * 100 + now.day + dayOffset;
    final rand = math.Random(daySeed);

    final List<SmartSuggestion> suggestions = [];
    final Set<String> addedDishIds = {};

    void addCandidate(Dish dish, SuggestionTag tag, String label, Color color, String reason) {
      if (!addedDishIds.contains(dish.id)) {
        addedDishIds.add(dish.id);
        suggestions.add(
          SmartSuggestion(
            dish: dish,
            tag: tag,
            tagLabel: label,
            tagColor: color,
            reasonDescription: reason,
          ),
        );
      }
    }

    // ── 1. Rotate User Favorites (Fit to Calorie Target) ──────────────────────
    if (favIds.isNotEmpty) {
      final userFavDishes = catalog.where((d) => favIds.contains(d.id)).toList();
      if (userFavDishes.isNotEmpty) {
        // Sort user favorites so ones closest to remaining budget or slot appropriateness come first
        userFavDishes.sort((a, b) {
          final diffA = (a.kcal - remainingKcal.clamp(250, 700)).abs();
          final diffB = (b.kcal - remainingKcal.clamp(250, 700)).abs();
          return diffA.compareTo(diffB);
        });

        // Rotate index by daySeed so the user gets varied favorites rather than the same one daily
        final rotatedFavIndex = daySeed % userFavDishes.length;
        final favPick = userFavDishes[rotatedFavIndex];
        addCandidate(
          favPick,
          SuggestionTag.favoriteFit,
          '❤️ Favorite Pick',
          const Color(0xFFEF4444),
          '${favPick.kcal} kcal • Fits your day',
        );

        // If user has multiple favorites, consider adding a second rotating favorite if slots permit
        if (userFavDishes.length > 1 && remainingKcal > 400) {
          final secondIndex = (rotatedFavIndex + 1) % userFavDishes.length;
          final secondFav = userFavDishes[secondIndex];
          addCandidate(
            secondFav,
            SuggestionTag.favoriteFit,
            '❤️ From Your Favorites',
            const Color(0xFFF43F5E),
            '${secondFav.kcal} kcal • Balanced nutrition',
          );
        }
      }
    }

    // ── 2. Calorie Match Target (Hits the sweet spot of remaining budget) ─────
    final idealSlotBudget = (remainingKcal > 100)
        ? (remainingKcal / 2).clamp(180, 650).round()
        : 220;

    final calorieMatches = catalog
        .where((d) => !addedDishIds.contains(d.id))
        .toList()
      ..sort((a, b) {
        final diffA = (a.kcal - idealSlotBudget).abs();
        final diffB = (b.kcal - idealSlotBudget).abs();
        return diffA.compareTo(diffB);
      });

    if (calorieMatches.isNotEmpty) {
      final match = calorieMatches[daySeed % math.min(calorieMatches.length, 3)];
      addCandidate(
        match,
        SuggestionTag.calorieMatch,
        '🎯 Calorie Match',
        const Color(0xFF10B981),
        '${match.kcal} kcal • Perfect fit for remaining budget',
      );
    }

    // ── 3. High Protein Fuel (Nutritional balance for active days) ────────────
    final proteinDishes = catalog
        .where((d) => !addedDishIds.contains(d.id) && d.protein >= 14)
        .toList();
    if (proteinDishes.isNotEmpty) {
      proteinDishes.sort((a, b) => b.protein.compareTo(a.protein));
      final proteinPick = proteinDishes[(daySeed + 2) % proteinDishes.length];
      addCandidate(
        proteinPick,
        SuggestionTag.highProtein,
        '💪 High Protein',
        const Color(0xFF0EA5E9),
        '${proteinPick.protein}g Protein • ${proteinPick.kcal} kcal',
      );
    }

    // ── 4. Fresh Discoveries (New dishes user hasn't favorited or viewed yet) ─
    final freshDishes = catalog
        .where((d) =>
            !addedDishIds.contains(d.id) &&
            !favIds.contains(d.id) &&
            !viewedIds.contains(d.id) &&
            d.rating >= 4.5)
        .toList();

    if (freshDishes.isNotEmpty) {
      freshDishes.shuffle(rand);
      final newDish = freshDishes.first;
      addCandidate(
        newDish,
        SuggestionTag.newDiscovery,
        '✨ Try Something New',
        const Color(0xFFA855F7),
        'Chef recommendation • Rated ${newDish.rating}★',
      );
    }

    // ── 5. Light Bite or Category Affinity ───────────────────────────────────
    if (suggestions.length < 5) {
      final lightBites = catalog
          .where((d) => !addedDishIds.contains(d.id) && d.kcal <= 300)
          .toList();
      if (lightBites.isNotEmpty) {
        final light = lightBites[(daySeed + 3) % lightBites.length];
        addCandidate(
          light,
          SuggestionTag.lightBite,
          '🥗 Light & Guilt-Free',
          const Color(0xFFF59E0B),
          'Under 300 kcal (${light.kcal} kcal)',
        );
      }
    }

    // Fallback if still under 4 items
    if (suggestions.length < 4) {
      for (final d in catalog) {
        if (!addedDishIds.contains(d.id)) {
          addCandidate(
            d,
            SuggestionTag.newDiscovery,
            '✨ Daily Suggestion',
            const Color(0xFF8B5CF6),
            '${d.kcal} kcal • Fresh today',
          );
          if (suggestions.length >= 5) break;
        }
      }
    }

    return suggestions;
  }

  /// Returns smart recommendations for the general app feed (e.g. Order Food screen),
  /// combining rotating favorites, recently viewed affinities, and fresh discoveries.
  List<Dish> getCuratedFeedDishes({int limit = 8}) {
    final favIds = FavoritesService.instance.favoriteIds;
    final viewedIds = FavoritesService.instance.recentlyViewedIds;
    final catalog = allDishes;

    final now = DateTime.now();
    final daySeed = now.year * 1000 + now.month * 100 + now.day;
    final rand = math.Random(daySeed);

    final List<Dish> result = [];
    final Set<String> added = {};

    // 1. Add rotating favorites so user sees their favorites, but varied daily
    if (favIds.isNotEmpty) {
      final favDishes = catalog.where((d) => favIds.contains(d.id)).toList();
      if (favDishes.isNotEmpty) {
        final pick = favDishes[daySeed % favDishes.length];
        result.add(pick);
        added.add(pick.id);
        if (favDishes.length > 1 && limit > 3) {
          final pick2 = favDishes[(daySeed + 1) % favDishes.length];
          if (!added.contains(pick2.id)) {
            result.add(pick2);
            added.add(pick2.id);
          }
        }
      }
    }

    // 2. Add dish with category affinity to recently viewed cards
    if (viewedIds.isNotEmpty) {
      final lastViewedId = viewedIds.first;
      final lastViewedDish = catalog.firstWhere(
        (d) => d.id == lastViewedId,
        orElse: () => catalog.first,
      );
      final categoryMatches = catalog
          .where((d) => !added.contains(d.id) && d.category == lastViewedDish.category)
          .toList();
      if (categoryMatches.isNotEmpty) {
        final catPick = categoryMatches[(daySeed + 2) % categoryMatches.length];
        result.add(catPick);
        added.add(catPick.id);
      }
    }

    // 3. Add fresh high-rated discovery that user hasn't favorited or viewed yet
    final freshDishes = catalog
        .where((d) =>
            !added.contains(d.id) &&
            !favIds.contains(d.id) &&
            !viewedIds.contains(d.id) &&
            d.rating >= 4.4)
        .toList();
    if (freshDishes.isNotEmpty) {
      freshDishes.shuffle(rand);
      final discovery = freshDishes.first;
      result.add(discovery);
      added.add(discovery.id);
    }

    // 4. Fill remaining spots from MockData.recommendedBreakfast and catalog
    for (final d in [...MockData.recommendedBreakfast, ...catalog]) {
      if (result.length >= limit) break;
      if (!added.contains(d.id)) {
        result.add(d);
        added.add(d.id);
      }
    }

    return result;
  }
}
