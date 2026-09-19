import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../routes/app_routes.dart';
import '../../services/menu_service.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/basket_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// A reusable category listing screen that displays dishes belonging to a
/// selected category (Meals, Chicken, Biriyani, Breakfast, Fish, Egg, Veg, etc.).
///
/// Fully integrated with [CartController] and the existing app navigation.
class CategoryListingScreen extends StatefulWidget {
  const CategoryListingScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  final CartController _cart = CartController.instance;
  final TextEditingController _searchController = TextEditingController();

  late String _selectedCategory;
  String _searchQuery = '';
  DishSortOption _activeSort = DishSortOption.popularity;
  bool _initialized = false;

  static const List<String> _availableCategories = [
    'Meals',
    'Chicken',
    'Biriyani',
    'Breakfast',
    'Fish',
    'Egg',
    'Veg',
    'Veg Rice',
    'All',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Meals';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.isNotEmpty) {
        _selectedCategory = arg;
      }
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(CategoryListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null &&
        widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory!;
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Dish> get _dishes {
    List<Dish> list;
    if (_searchQuery.trim().isEmpty) {
      list = List<Dish>.from(MockData.getDishesForCategory(_selectedCategory));
    } else {
      final q = _searchQuery.toLowerCase().trim();
      final allDishes = MenuService.instance.dishes.isNotEmpty
          ? MenuService.instance.dishes
          : MockData.dishes;
      final seen = <String>{};
      list = allDishes.where((d) {
        final matches = d.name.toLowerCase().contains(q) ||
            (d.subtitle != null && d.subtitle!.toLowerCase().contains(q)) ||
            d.category.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.ingredients.any((ing) => ing.toLowerCase().contains(q));
        return matches && seen.add(d.name.toLowerCase().trim());
      }).toList();
    }

    switch (_activeSort) {
      case DishSortOption.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case DishSortOption.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case DishSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DishSortOption.popularity:
        // Default category ordering / popularity
        break;
    }

    return list;
  }

  void _openProduct(Dish dish) {
    Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: dish);
  }

  void _openSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort Dishes By',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _sortTile(ctx, 'Popularity (Default)', DishSortOption.popularity),
              _sortTile(ctx, 'Price: Low to High', DishSortOption.priceLowHigh),
              _sortTile(ctx, 'Price: High to Low', DishSortOption.priceHighLow),
              _sortTile(ctx, 'Customer Rating (4.5+)', DishSortOption.rating),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortTile(BuildContext ctx, String label, DishSortOption option) {
    final selected = _activeSort == option;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.copper : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.copper, size: 20)
          : const Icon(Icons.circle_outlined, color: AppColors.hint, size: 20),
      onTap: () {
        setState(() => _activeSort = option);
        Navigator.of(ctx).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _appBar(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _searchBar(),
            ),
            const SizedBox(height: 12),
            _categoryPills(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.trim().isNotEmpty
                        ? '${_dishes.length} SEARCH RESULTS'
                        : '${_dishes.length} ITEMS',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: _openSortModal,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            _activeSort == DishSortOption.popularity ? 'SORT BY' : 'SORTED',
                            style: const TextStyle(
                              color: AppColors.copper,
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.swap_vert, color: AppColors.copper, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _cart,
                builder: (context, _) => _buildBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_cart.isNotEmpty)
                BasketBar(
                  itemCount: _cart.totalQuantity,
                  label: 'GO TO CART',
                  onNext: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                ),
              const ParagonBottomNav(current: ParagonTab.home),
            ],
          );
        },
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _selectedCategory,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                    color: AppColors.textPrimary,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.cart),
                  ),
                  if (!_cart.isEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        alignment: Alignment.center,
                        child: Text(
                          '${_cart.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search dishes across all categories...',
                hintStyle: TextStyle(
                  color: AppColors.hint,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _categoryPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availableCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _availableCategories[i];
          final isSelected =
              cat.toLowerCase() == _selectedCategory.toLowerCase();
          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() {
                  _selectedCategory = cat;
                  _searchQuery = '';
                  _searchController.clear();
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.copper : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.copper : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final items = _dishes;
    if (items.isEmpty) {
      final isSearching = _searchQuery.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant_outlined,
                  size: 54, color: AppColors.hint),
              const SizedBox(height: 14),
              Text(
                isSearching
                    ? 'No dishes matching "$_searchQuery"'
                    : 'No dishes found in $_selectedCategory',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                isSearching
                    ? 'Try searching for another dish or ingredient across all categories.'
                    : 'Try searching for another dish or choose a different category.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Text('Clear search'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final childAspectRatio = screenWidth < 380 ? 0.60 : 0.65;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final dish = items[i];
        final inCart = _cart.contains(dish);
        final qty = _cart.quantityOf(dish);

        return _CategoryFoodCard(
          dish: dish,
          inCart: inCart,
          quantity: qty,
          onTap: () => _openProduct(dish),
          onAdd: () => _cart.add(dish),
          onIncrement: () => _cart.increment(dish),
          onDecrement: () => _cart.decrement(dish),
        );
      },
    );
  }
}

/// Food card displayed in the 2-column category grid matching the Food Planner design system.
class _CategoryFoodCard extends StatelessWidget {
  const _CategoryFoodCard({
    required this.dish,
    required this.inCart,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Dish dish;
  final bool inCart;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image with rounded corners matching Food Planner
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  child: NetworkImageWithFallback(
                    url: dish.imageUrl,
                    fallbackIcon: Icons.restaurant,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title & Veg / Non-Veg Indicator
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dish.isVeg
                        ? const Color(0xFF22C55E)
                        : AppColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dish.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Price & Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹ ${dish.price.toInt()}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF5B942), size: 12),
                    const SizedBox(width: 2),
                    Text(
                      dish.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Macro details (Calories & Weight)
            Text(
              '🔥 ${dish.kcal} kcal · ⚖️ ${dish.grams} gm',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Stepper / ADD Button
            _CategoryQuantityButton(
              quantity: quantity,
              onAdd: onAdd,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact full-width quantity button matching the Food Planner design.
class _CategoryQuantityButton extends StatelessWidget {
  const _CategoryQuantityButton({
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: double.infinity,
        height: 32,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 14, color: Colors.white),
          label: const Text(
            'ADD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accentRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDecrement,
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
