import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import '../../models/menu_category.dart';
import '../../models/promo_banner.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/menu_service.dart';
import '../../state/cart_controller.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_picker_sheet.dart';
import '../../widgets/basket_bar.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/menu_list_tile.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// The main "Order Food" menu: interactive delivery header, search, promo carousel,
/// category tabs with dynamic filtering, sort options, clickable categories and dish rails.
class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  final PageController _promoController = PageController(viewportFraction: 0.9);
  int _selectedTab = 0;
  int _promoPage = 0;
  String _activeCategoryFilter = 'All';
  DishSortOption _activeSort = DishSortOption.popularity;

  final CartController _cart = CartController.instance;
  List<Dish> get _dishes => MenuService.instance.dishes;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _openProduct(Dish dish) {
    Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: dish);
  }

  void _openCategory(String category) {
    Navigator.of(context).pushNamed(
      AppRoutes.categoryListing,
      arguments: category,
    );
  }

  void _add(Dish dish) => _cart.add(dish);

  void _openAddressPicker() {
    AddressPickerSheet.show(
      context: context,
      onAddressSelected: (addr) {
        setState(() {}); // refresh delivery location header & fees
      },
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

  List<Dish> _applyFiltersAndSort(List<Dish> source) {
    var list = List<Dish>.from(source);

    // Filter by Category Tab
    if (_activeCategoryFilter != 'All' &&
        _activeCategoryFilter.toLowerCase() != 'frequent order' &&
        _activeCategoryFilter.isNotEmpty) {
      final filter = _activeCategoryFilter.toLowerCase();
      list = list.where((d) {
        if (filter == 'veg') return d.isVeg;
        final cat = d.category.toLowerCase();
        if (filter == 'breakfast') return cat.contains('breakfast') || cat.contains('dosa') || cat.contains('idli');
        if (filter == 'lunch') return cat.contains('lunch') || cat.contains('biriyani') || cat.contains('rice') || cat.contains('curry');
        if (filter == 'dinner') return cat.contains('dinner') || cat.contains('roti') || cat.contains('starter');
        if (filter == 'beverages') return cat.contains('beverage') || cat.contains('juice') || cat.contains('shake') || cat.contains('tea');
        if (filter == 'desserts') return cat.contains('dessert') || cat.contains('sweet') || cat.contains('ice cream');
        return cat.contains(filter) || d.name.toLowerCase().contains(filter);
      }).toList();
      if (list.isEmpty) list = List<Dish>.from(source);
    }

    // Sort
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

  @override
  Widget build(BuildContext context) {
    final filteredDishes = _applyFiltersAndSort(_dishes);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _header(),
            const SizedBox(height: 10),
            const DashboardTabBar(activeId: 'order_food'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _searchBar(),
            ),
            const SizedBox(height: 20),
            _promoCarousel(),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _menuSortRow(),
            ),
            const SizedBox(height: 14),
            _categoryTabs(),
            const SizedBox(height: 18),
            _featuredRail(filteredDishes),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _sectionHeader('Explore by Category'),
            ),
            const SizedBox(height: 14),
            _categoryCircles(),
            const SizedBox(height: 30),
            _foodPlannerSection(),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: BasketBar(
                    itemCount: _cart.totalQuantity,
                    label: 'GO TO CART',
                    onNext: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                  ),
                ),
              const ParagonBottomNav(current: ParagonTab.home),
            ],
          );
        },
      ),
    );
  }

  // ---- Sections ----------------------------------------------------------

  Widget _header() {
    final currentArea = LocationService.instance.currentDeliveryArea;
    final user = AuthService.instance.currentUser;
    final userInitial = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName.trim()[0].toUpperCase()
        : (user?.email.isNotEmpty == true ? user!.email[0].toUpperCase() : 'G');

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.account),
            child: ClipOval(
              child: Container(
                width: 40,
                height: 40,
                color: AppColors.maroon,
                alignment: Alignment.center,
                child: (user?.photoUrl.trim().isNotEmpty == true)
                    ? NetworkImageWithFallback(
                        url: user!.photoUrl.trim(),
                        fallbackIcon: Icons.person,
                      )
                    : Text(
                        userInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _openAddressPicker,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deliver to',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.accentRed, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          currentArea.isNotEmpty ? currentArea : MockData.deliveryArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textPrimary, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Dedicated Track Live Order Button ─────────────────────────
          IconButton(
            tooltip: 'Track Live Order',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.delivery_dining_outlined,
                    color: AppColors.copper, size: 24),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.trackOrder),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textPrimary),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              'Search your dishes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _promoController,
            itemCount: MockData.promos.length,
            onPageChanged: (i) => setState(() => _promoPage = i),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PromoCard(promo: MockData.promos[i]),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(MockData.promos.length, (i) {
            final active = i == _promoPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.accentRed : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

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

  Widget _categoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.categoryTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (context, i) {
          final isFrequent = i == 0;
          return GestureDetector(
            onTap: () {
              if (isFrequent) {
                setState(() {
                  _selectedTab = 0;
                  _activeCategoryFilter = 'All';
                });
              } else {
                _openCategory(MockData.categoryTabs[i]);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MockData.categoryTabs[i],
                  style: TextStyle(
                    color: isFrequent
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: isFrequent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                if (isFrequent)
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

  Widget _featuredRail(List<Dish> dishes) {
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        final displayList =
            dishes.isNotEmpty ? dishes : MockData.frequentOrders;
        return SizedBox(
          height: 256,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final dish = displayList[i];
              return FeaturedDishCard(
                dish: dish,
                inCart: _cart.contains(dish),
                onTap: () => _openProduct(dish),
                onAdd: () => _add(dish),
              );
            },
          ),
        );
      },
    );
  }

  Widget _categoryCircles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        itemCount: MockData.categories.length,
        itemBuilder: (context, i) {
          final cat = MockData.categories[i];
          return _CategoryCircle(
            category: cat,
            onTap: () => _openCategory(cat.name),
          );
        },
      ),
    );
  }

  Widget _foodPlannerSection() {
    final planner = FoodPlannerController.instance;
    return AnimatedBuilder(
      animation: planner,
      builder: (context, _) {
        final hasMeals = planner.plannedMeals.isNotEmpty;
        final currentMeal = hasMeals ? planner.plannedMeals.first : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C1810),
                  AppColors.backgroundElevated,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.copper.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.copper.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_month_rounded,
                          color: AppColors.copper, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FOOD PLANNER & MACROS',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Scheduled Meals & Calorie Tracking',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.maroon.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.maroon),
                      ),
                      child: const Text(
                        '15% OFF',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (currentMeal != null) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: NetworkImageWithFallback(
                            url: currentMeal.imageUrl,
                            fallbackIcon: Icons.restaurant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Planned: ${currentMeal.dishName}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${currentMeal.mealType.label.toUpperCase()} · ${currentMeal.timeSlot} · ${currentMeal.calories} kcal',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  const Text(
                    'Plan your weekly breakfast, lunch & dinner with zero hassle.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 16, color: AppColors.copper),
                        SizedBox(width: 4),
                        Text(
                          '2,000 kcal Target',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.foodPlanner),
                      icon: const Icon(Icons.arrow_forward, size: 14),
                      label: Text(
                        hasMeals ? 'OPEN PLANNER' : 'START PLANNING',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _combinationList() {
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final dish in MockData.combinationBreakfast)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MenuListTile(
                    dish: dish,
                    inCart: _cart.contains(dish),
                    onTap: () => _openProduct(dish),
                    onAdd: () => _add(dish),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _recommendedRail() {
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        return SizedBox(
          height: 272,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: MockData.recommendedBreakfast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final dish = MockData.recommendedBreakfast[i];
              return RecommendedDishCard(
                dish: dish,
                inCart: _cart.contains(dish),
                onTap: () => _openProduct(dish),
                onAdd: () => _add(dish),
              );
            },
          ),
        );
      },
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
}

/// A single promo card in the carousel.
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final PromoBanner promo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkImageWithFallback(url: promo.imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promo.headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use code',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                Text(
                  promo.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ORDER NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A round category shortcut with its label and tap callback.
class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({
    required this.category,
    this.onTap,
  });

  final MenuCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: NetworkImageWithFallback(
                    url: category.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
