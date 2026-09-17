import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/add_button.dart';
import '../../widgets/basket_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';
import '../../widgets/price_text.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/veg_indicator.dart';

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
    final raw = MockData.getDishesForCategory(_selectedCategory);
    if (_searchQuery.trim().isEmpty) return raw;

    final q = _searchQuery.toLowerCase().trim();
    return raw.where((d) {
      return d.name.toLowerCase().contains(q) ||
          (d.subtitle != null && d.subtitle!.toLowerCase().contains(q)) ||
          d.description.toLowerCase().contains(q);
    }).toList();
  }

  void _openProduct(Dish dish) {
    Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: dish);
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
            const SizedBox(height: 10),
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
          if (_cart.isEmpty) {
            return const ParagonBottomNav(current: ParagonTab.home);
          }
          return BasketBar(
            itemCount: _cart.totalQuantity,
            label: 'GO TO CART',
            onNext: () => Navigator.of(context).pushNamed(AppRoutes.cart),
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
              decoration: InputDecoration(
                hintText: 'Search in $_selectedCategory dishes...',
                hintStyle: const TextStyle(
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
                'No dishes found in $_selectedCategory',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try searching for another dish or choose a different category.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.69,
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

/// Food card displayed in the 2-column category grid.
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image
            SizedBox(
              height: 114,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageWithFallback(
                    url: dish.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: VegIndicator(isVeg: dish.isVeg, size: 12),
                    ),
                  ),
                  if (dish.rating > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Color(0xFFF5B942), size: 12),
                            const SizedBox(width: 3),
                            Text(
                              dish.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dish.subtitle ?? dish.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // Price + Add button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: PriceText(price: dish.price, size: 15),
                        ),
                        const SizedBox(width: 4),
                        if (quantity > 0)
                          QuantityStepper(
                            quantity: quantity,
                            size: 24,
                            fontSize: 12,
                            onIncrement: onIncrement,
                            onDecrement: onDecrement,
                          )
                        else
                          AddCircleButton(
                            onTap: onAdd,
                            inCart: false,
                            size: 30,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
