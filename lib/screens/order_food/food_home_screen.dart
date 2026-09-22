import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/menu_category.dart';
import '../../models/promo_banner.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/menu_service.dart';
import '../../services/session_manager.dart';
import '../../state/cart_controller.dart';
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


  List<Dish> _applyFiltersAndSort(List<Dish> source) {
    List<Dish> list;

    // Filter by Category Tab: Frequent order tab displays frequentOrders
    if (_selectedTab == 0 || _activeCategoryFilter.toLowerCase() == 'frequent order') {
      list = List<Dish>.from(MockData.frequentOrders);
    } else if (_activeCategoryFilter != 'All' && _activeCategoryFilter.isNotEmpty) {
      final filter = _activeCategoryFilter.toLowerCase();
      list = source.where((d) {
        final cat = d.category.toLowerCase();
        final name = d.name.toLowerCase();
        if (filter == 'veg') return d.isVeg;
        if (filter == 'non-veg' || filter == 'non veg') return !d.isVeg;
        if (filter == 'fish') {
          return cat.contains('fish') || cat.contains('seafood') || name.contains('fish') || name.contains('prawn') || name.contains('meen');
        }
        if (filter == 'chicken') return cat.contains('chicken') || name.contains('chicken') || name.contains('kozhi');
        if (filter == 'egg') return cat.contains('egg') || name.contains('egg') || name.contains('mutta');
        if (filter == 'beef') return cat.contains('beef') || name.contains('beef');
        if (filter == 'mutton') return cat.contains('mutton') || name.contains('mutton');
        if (filter == 'breakfast') {
          return cat.contains('breakfast') || cat.contains('dosa') || cat.contains('idli') || name.contains('dosa') || name.contains('idli') || name.contains('appam') || name.contains('puttu');
        }
        if (filter == 'lunch') return cat.contains('lunch') || cat.contains('biriyani') || cat.contains('rice') || cat.contains('curry');
        if (filter == 'dinner') return cat.contains('dinner') || cat.contains('roti') || cat.contains('starter');
        if (filter == 'beverages') return cat.contains('beverage') || cat.contains('juice') || cat.contains('shake') || cat.contains('tea');
        if (filter == 'desserts') return cat.contains('dessert') || cat.contains('sweet') || cat.contains('ice cream');
        return cat.contains(filter) || name.contains(filter);
      }).toList();

      if (list.isEmpty) {
        list = MockData.getDishesForCategory(_activeCategoryFilter);
      }
      if (list.isEmpty) {
        list = source.where((d) => d.category.toLowerCase().contains(filter) || d.name.toLowerCase().contains(filter)).toList();
      }
    } else {
      list = List<Dish>.from(source);
    }

    // Deduplicate by lowercase name to ensure zero duplicate cards
    final seen = <String>{};
    list = list.where((d) => seen.add(d.name.toLowerCase().trim())).toList();

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
                          (currentArea.isNotEmpty && !currentArea.toLowerCase().contains('palazhi'))
                              ? currentArea
                              : (SessionManager.instance.getSelectedAddress()?.label ?? 'Current Location'),
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
            Expanded(
              child: Text(
                'Search dishes across all categories',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'MENU',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
      ),
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
          final isSelected = _selectedTab == i;
          final tabName = MockData.categoryTabs[i];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = i;
                _activeCategoryFilter = i == 0 ? 'All' : tabName;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabName,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                if (isSelected)
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
        if (dishes.isEmpty) {
          return Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'No $_activeCategoryFilter dishes available right now',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return SizedBox(
          height: 256,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dishes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final dish = dishes[i];
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
