import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../services/menu_service.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/nutrition_badge.dart';
import '../../widgets/payment_gateway_sheet.dart';
import '../../widgets/price_text.dart';
import '../../widgets/veg_indicator.dart';
import 'takeaway_order_card.dart';

/// The Takeaway ordering menu: category tabs, dishes with +/- quantity controls,
/// interactive takeaway search, cart modal sheet with food items & placed orders,
/// and floating bottom basket bar.
class TakeawayMenuScreen extends StatefulWidget {
  const TakeawayMenuScreen({super.key});

  @override
  State<TakeawayMenuScreen> createState() => _TakeawayMenuScreenState();
}

class _TakeawayMenuScreenState extends State<TakeawayMenuScreen> {
  int _selectedTab = 0;
  final TakeawayController _ctrl = TakeawayController.instance;

  DishSortOption _activeSort = DishSortOption.popularity;

  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openProduct(Dish dish) {
    Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: dish);
  }

  List<Dish> _applySort(List<Dish> source) {
    var list = List<Dish>.from(source);
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
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  Future<void> _onNext() async {
    if (_ctrl.isCartEmpty || _isSubmitting) return;

    await PaymentGatewaySheet.show(
      context: context,
      amount: _ctrl.grandTotal,
      isTakeaway: true,
      onPaymentSuccess: (transactionId, paymentMode) async {
        setState(() => _isSubmitting = true);
        try {
          await _ctrl.placeOrder(
            paymentMethod: paymentMode,
            transactionId: transactionId,
          );
          if (mounted) {
            setState(() => _isSubmitting = false);
            AppBanner.showSuccess(
              context,
              'Payment successful via $paymentMode! Takeaway order placed.',
              title: 'Order Confirmed',
            );
            Navigator.of(context).pushNamed(AppRoutes.takeawaySuccess);
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            AppBanner.showError(
              context,
              'Failed to place order: $e',
              title: 'Order Error',
            );
          }
        }
      },
    );
  }

  List<Dish> _getDishesForCategory(String category) {
    final allDishes = MenuService.instance.dishes.isNotEmpty
        ? MenuService.instance.dishes
        : MockData.dishes;
    final cat = category.toLowerCase().trim();
    if (cat == 'frequent order') {
      return _applySort(MockData.frequentOrders);
    }
    final matches = allDishes.where((dish) {
      final dishCat = dish.category.toLowerCase().trim();
      if (dishCat == cat) return true;
      if (cat == 'veg' && dish.isVeg) return true;
      if (cat == 'breakfast' &&
          (dishCat == 'breakfast' ||
              dish.id == 'plain_dosa' ||
              dish.id == 'kuzhipaniyaram' ||
              dish.name.toLowerCase().contains('dosa') ||
              dish.name.toLowerCase().contains('idli') ||
              dish.name.toLowerCase().contains('appam') ||
              dish.name.toLowerCase().contains('puttu'))) {
        return true;
      }
      if (cat == 'fish' &&
          (dishCat == 'fish' ||
              dish.name.toLowerCase().contains('fish') ||
              dish.name.toLowerCase().contains('meen'))) {
        return true;
      }
      if (cat == 'egg' &&
          (dishCat == 'egg' ||
              dish.name.toLowerCase().contains('egg') ||
              dish.name.toLowerCase().contains('mutta'))) {
        return true;
      }
      if (cat == 'chicken' &&
          (dishCat == 'chicken' ||
              dish.name.toLowerCase().contains('chicken'))) {
        return true;
      }
      return false;
    }).toList();
    return _applySort(matches);
  }

  List<Dish> _getSearchResults() {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    final allDishes = MenuService.instance.dishes.isNotEmpty
        ? MenuService.instance.dishes
        : MockData.dishes;
    final matches = allDishes.where((d) {
      return d.name.toLowerCase().contains(q) ||
          (d.subtitle != null && d.subtitle!.toLowerCase().contains(q)) ||
          d.category.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q) ||
          d.ingredients.any((ing) => ing.toLowerCase().contains(q));
    }).toList();
    return _applySort(matches);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Stack(
              children: [
                ListView(
                  padding: EdgeInsets.only(
                    bottom: _ctrl.isCartEmpty ? 24 : 96,
                  ),
                  children: [
                    _header(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _menuSortRow(),
                    ),
                    const SizedBox(height: 14),
                    if (_isSearching) ...[
                      _searchBody(),
                    ] else ...[
                      _categoryTabs(),
                      const SizedBox(height: 18),
                      if (_selectedTab == 0) ...[
                        _featuredRail(),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _sectionHeader('Combination Breakfast'),
                        ),
                        const SizedBox(height: 14),
                        _combinationList(),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _sectionHeader('Recommended Breakfast'),
                        ),
                        const SizedBox(height: 14),
                        _recommendedRail(),
                      ] else ...[
                        _categoryFilteredList(),
                      ],
                    ],
                  ],
                ),
                // ── Floating bottom basket bar ───────────────────────────
                if (!_ctrl.isCartEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _TakeawayBasketBar(
                      itemCount: _ctrl.totalQuantity,
                      onNext: _onNext,
                      isSubmitting: _isSubmitting,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _header() {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchCtrl.clear();
                  _searchQuery = '';
                });
              },
            ),
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search dishes across all categories...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchCtrl.clear();
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(Icons.close,
                            color: AppColors.textSecondary, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _cartIconWithBadge(),
          ],
        ),
      );
    }

    final activeOutlet = _ctrl.activeRestaurant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.takeawaySelectRestaurant),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Takeaway orders',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.copper,
                        ),
                      ],
                    ),
                    Text(
                      '${activeOutlet.name} • ${activeOutlet.branch}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () => setState(() => _isSearching = true),
          ),
          _cartIconWithBadge(),
        ],
      ),
    );
  }

  Widget _cartIconWithBadge() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined,
              color: AppColors.textPrimary),
          onPressed: () => _openTakeawayCartModal(context),
        ),
        if (_ctrl.totalQuantity > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              alignment: Alignment.center,
              child: Text(
                '${_ctrl.totalQuantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Search Body ─────────────────────────────────────────────────────────────

  Widget _searchBody() {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Categories',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockData.categoryTabs.map((cat) {
                return ActionChip(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  label: Text(
                    cat,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchCtrl.text = cat;
                      _searchQuery = cat;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Popular Suggestions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Dosa',
                'Biriyani',
                'Chicken',
                'Fish',
                'Paniyaram',
                'Puttu'
              ].map((tag) {
                return ActionChip(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  label: Text(
                    tag,
                    style:
                        const TextStyle(color: AppColors.copper, fontSize: 13),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchCtrl.text = tag;
                      _searchQuery = tag;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    final results = _getSearchResults();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Search Results ("$query") • ${results.length} found'),
          const SizedBox(height: 14),
          if (results.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.search_off,
                        color: AppColors.textSecondary, size: 54),
                    const SizedBox(height: 16),
                    Text(
                      'No dishes found matching "$query"',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Try searching for dosa, chicken, biriyani, fish, etc.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...results.map((dish) {
              final qty = _ctrl.quantityOf(dish);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TakeawayListTile(
                  dish: dish,
                  quantity: qty,
                  onTap: () => _openProduct(dish),
                  onAdd: () => _ctrl.add(dish),
                  onIncrement: () => _ctrl.increment(dish),
                  onDecrement: () => _ctrl.decrement(dish),
                ),
              );
            }),
        ],
      ),
    );
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
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary, size: 20),
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
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.copper, size: 20)
          : const Icon(Icons.circle_outlined, color: AppColors.hint, size: 20),
      onTap: () {
        setState(() => _activeSort = option);
        Navigator.of(ctx).pop();
      },
    );
  }

  // ── Menu & Sort Row ─────────────────────────────────────────────────────────

  Widget _menuSortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'MENU',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                const SizedBox(width: 6),
                const Icon(Icons.swap_vert, color: AppColors.copper, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Category Tabs ───────────────────────────────────────────────────────────

  Widget _categoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.categoryTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (context, i) {
          final selected = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MockData.categoryTabs[i],
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                if (selected)
                  Container(
                    width: 22,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Category Filtered List ──────────────────────────────────────────────────

  Widget _categoryFilteredList() {
    final category = MockData.categoryTabs[_selectedTab];
    final dishes = _getDishesForCategory(category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('$category Dishes (${dishes.length})'),
          const SizedBox(height: 14),
          if (dishes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.restaurant_menu,
                        color: AppColors.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No dishes available in $category',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...dishes.map((dish) {
              final qty = _ctrl.quantityOf(dish);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TakeawayListTile(
                  dish: dish,
                  quantity: qty,
                  onTap: () => _openProduct(dish),
                  onAdd: () => _ctrl.add(dish),
                  onIncrement: () => _ctrl.increment(dish),
                  onDecrement: () => _ctrl.decrement(dish),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Featured Rail ───────────────────────────────────────────────────────────

  Widget _featuredRail() {
    final dishes = _applySort(MockData.frequentOrders);
    return SizedBox(
      height: 264,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dishes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final dish = dishes[i];
          final qty = _ctrl.quantityOf(dish);
          return _TakeawayDishCard(
            dish: dish,
            quantity: qty,
            onTap: () => _openProduct(dish),
            onAdd: () => _ctrl.add(dish),
            onIncrement: () => _ctrl.increment(dish),
            onDecrement: () => _ctrl.decrement(dish),
          );
        },
      ),
    );
  }

  // ── Combination List ────────────────────────────────────────────────────────

  Widget _combinationList() {
    final dishes = _applySort(MockData.combinationBreakfast);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: dishes.map((dish) {
          final qty = _ctrl.quantityOf(dish);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TakeawayListTile(
              dish: dish,
              quantity: qty,
              onTap: () => _openProduct(dish),
              onAdd: () => _ctrl.add(dish),
              onIncrement: () => _ctrl.increment(dish),
              onDecrement: () => _ctrl.decrement(dish),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Recommended Rail ────────────────────────────────────────────────────────

  Widget _recommendedRail() {
    final dishes = _applySort(MockData.recommendedBreakfast);
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dishes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final dish = dishes[i];
          final qty = _ctrl.quantityOf(dish);
          return _TakeawayRecommendedCard(
            dish: dish,
            quantity: qty,
            onTap: () => _openProduct(dish),
            onAdd: () => _ctrl.add(dish),
            onIncrement: () => _ctrl.increment(dish),
            onDecrement: () => _ctrl.decrement(dish),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  // ── Takeaway Cart & Orders Bottom Sheet ──────────────────────────────────────

  void _openTakeawayCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            final restaurant = _ctrl.selectedRestaurant ??
                (MockData.restaurants.isNotEmpty
                    ? MockData.restaurants.first
                    : const Restaurant(
                        id: 'rest_main',
                        name: 'Downtown Bistro',
                        address: 'Kannur Road',
                        city: 'Calicut',
                      ));

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: AppColors.copper, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Takeaway Basket & Orders',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceLight, height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Empty State if both cart and orders are empty
                        if (_ctrl.isCartEmpty && _ctrl.hasNoOrders)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.shopping_cart_outlined,
                                      color: AppColors.textSecondary, size: 40),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Your takeaway basket is empty',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Add dishes from the menu to place a takeaway order.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Section 1: In Your Basket
                        if (!_ctrl.isCartEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ITEMS IN BASKET (${_ctrl.totalQuantity})',
                                style: const TextStyle(
                                  color: AppColors.copper,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _ctrl.clearCart(),
                                child: const Text(
                                  'Clear Basket',
                                  style: TextStyle(
                                    color: AppColors.accentRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Pickup Branch Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_outlined,
                                    color: AppColors.copper, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Pickup at ${restaurant.address}, ${restaurant.city}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Food items in takeaway basket
                          ..._ctrl.cartItems.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 54,
                                      height: 54,
                                      child: NetworkImageWithFallback(
                                        url: item.dish.imageUrl,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.dish.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            VegIndicator(
                                                isVeg: item.dish.isVeg),
                                            const SizedBox(width: 8),
                                            PriceText(
                                              price: item.dish.price,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  _QuantityStepperButton(
                                    quantity: item.quantity,
                                    onAdd: () => _ctrl.add(item.dish),
                                    onIncrement: () =>
                                        _ctrl.increment(item.dish),
                                    onDecrement: () =>
                                        _ctrl.decrement(item.dish),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '\$${item.lineTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                          // Bill Breakdown
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Item Total',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '\$${_ctrl.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Takeaway Packaging',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Free',
                                      style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                      color: AppColors.surfaceLight, height: 1),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '\$${_ctrl.grandTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.accentRed,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Confirm & Place Order Action
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _isSubmitting
                                  ? null
                                  : () async {
                                      Navigator.of(sheetContext).pop();
                                      await _onNext();
                                    },
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'CONFIRM & PLACE ORDER',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                            ),
                          ),
                          if (!_ctrl.hasNoOrders) const SizedBox(height: 28),
                        ],

                        // Section 2: Placed Takeaway Orders
                        if (!_ctrl.hasNoOrders) ...[
                          Row(
                            children: [
                              const Icon(Icons.receipt_long,
                                  color: AppColors.copper, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'PLACED TAKEAWAY ORDERS (${_ctrl.orders.length})',
                                style: const TextStyle(
                                  color: AppColors.copper,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._ctrl.orders.map((order) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TakeawayOrderCard(order: order),
                              )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Takeaway Dish Card (Frequent order rail) ───────────────────────────────────

class _TakeawayDishCard extends StatelessWidget {
  const _TakeawayDishCard({
    required this.dish,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Dish dish;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: NetworkImageWithFallback(url: dish.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DishBadges(dish: dish),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PriceText(price: dish.price, size: 16),
                        _QuantityStepperButton(
                          quantity: quantity,
                          onAdd: onAdd,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Takeaway List Tile (Category Dishes & Combinations) ────────────────────────

class _TakeawayListTile extends StatelessWidget {
  const _TakeawayListTile({
    required this.dish,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Dish dish;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final title = dish.subtitle == null
        ? dish.name
        : '${dish.name} - ${dish.subtitle}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 74,
                    height: 74,
                    child: NetworkImageWithFallback(url: dish.imageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DishBadges(dish: dish),
                      const SizedBox(height: 8),
                      PriceText(price: dish.price, size: 15),
                    ],
                  ),
                ),
                _QuantityStepperButton(
                  quantity: quantity,
                  onAdd: onAdd,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Takeaway Recommended Card ─────────────────────────────────────────────────

class _TakeawayRecommendedCard extends StatelessWidget {
  const _TakeawayRecommendedCard({
    required this.dish,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Dish dish;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final title = dish.subtitle == null
        ? dish.name
        : '${dish.name} - ${dish.subtitle}';

    return SizedBox(
      width: 175,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: NetworkImageWithFallback(url: dish.imageUrl),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    PriceText(price: dish.price, size: 15),
                    const SizedBox(height: 8),
                    DishBadges(dish: dish),
                    const SizedBox(height: 12),
                    _QuantityStepperButton(
                      quantity: quantity,
                      onAdd: onAdd,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quantity Stepper Button ───────────────────────────────────────────────────

class _QuantityStepperButton extends StatelessWidget {
  const _QuantityStepperButton({
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
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary, size: 18),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove, color: AppColors.textPrimary, size: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add, color: AppColors.textPrimary, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating Takeaway Basket Bar ──────────────────────────────────────────────

class _TakeawayBasketBar extends StatelessWidget {
  const _TakeawayBasketBar({
    required this.itemCount,
    required this.onNext,
    this.isSubmitting = false,
  });

  final int itemCount;
  final VoidCallback onNext;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2127),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined,
              color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$itemCount ${itemCount == 1 ? 'Item' : 'Items'} added',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: isSubmitting ? null : onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                      ),
                    )
                  : const Text(
                      'NEXT',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
