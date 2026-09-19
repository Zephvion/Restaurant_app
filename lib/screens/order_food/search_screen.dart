import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../routes/app_routes.dart';
import '../../services/menu_service.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/menu_list_tile.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Search — a frosted overlay over the menu with a live dish filter and two
/// quick actions ("Repeat last order", "Help me choose").
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final CartController _cart = CartController.instance;
  String _query = '';

  List<Dish> get _all {
    final list = MenuService.instance.dishes.isNotEmpty
        ? MenuService.instance.dishes
        : MockData.dishes;
    final seen = <String>{};
    return list.where((d) => seen.add(d.name.toLowerCase().trim())).toList();
  }

  List<Dish> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _all.where((d) {
      return d.name.toLowerCase().contains(q) ||
          (d.subtitle != null && d.subtitle!.toLowerCase().contains(q)) ||
          d.category.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q) ||
          d.ingredients.any((ing) => ing.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Blurred food backdrop.
          const Positioned.fill(
            child: NetworkImageWithFallback(url: MockData.orderFoodHero),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                color: AppColors.background.withOpacity(0.82),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Text('Search',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _searchField(),
                ),
                Expanded(
                  child: _query.trim().isEmpty
                      ? _suggestions()
                      : _resultsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              cursorColor: AppColors.copper,
              decoration: const InputDecoration(
                hintText: 'Search dishes across all categories...',
                hintStyle: TextStyle(color: AppColors.hint, fontSize: 14),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                setState(() => _query = '');
              },
              child: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _suggestions() {
    const popularCategories = [
      'Biriyani',
      'Meals',
      'Dosa',
      'Chicken',
      'Fish',
      'Egg',
      'Veg',
      'Beverages',
      'Desserts',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _SuggestionTile(
          icon: Icons.replay,
          label: 'Repeat last order',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.previousOrder),
        ),
        const SizedBox(height: 14),
        _SuggestionTile(
          icon: Icons.help_outline,
          label: 'Help me choose',
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.foodHome),
        ),
        const SizedBox(height: 24),
        Text(
          'POPULAR CATEGORIES & DISHES',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularCategories.map((cat) {
            return ActionChip(
              backgroundColor: AppColors.backgroundElevated,
              side: const BorderSide(color: AppColors.border),
              label: Text(
                cat,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                _controller.text = cat;
                setState(() => _query = cat);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _resultsList() {
    final results = _results;
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48, color: AppColors.hint),
              const SizedBox(height: 12),
              Text(
                'No dishes matching "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try searching across other categories, ingredients, or dish names.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final dish = results[i];
          return MenuListTile(
            dish: dish,
            inCart: _cart.contains(dish),
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.productDetail, arguments: dish),
            onAdd: () => _cart.add(dish),
          );
        },
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundElevated,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.copper, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
