import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/menu_category.dart';
import '../../models/promo_banner.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/basket_bar.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/menu_list_tile.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// The main "Order Food" menu: delivery header, search, promo carousel,
/// category tabs, featured dishes, category circles and the breakfast lists.
class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  final PageController _promoController = PageController(viewportFraction: 0.9);
  int _promoPage = 0;
  int _selectedTab = 0;

  final CartController _cart = CartController.instance;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _openProduct(Dish dish) {
    Navigator.of(context)
        .pushNamed(AppRoutes.productDetail, arguments: dish);
  }

  void _add(Dish dish) => _cart.add(dish);

  @override
  Widget build(BuildContext context) {
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
            _featuredRail(),
            const SizedBox(height: 26),
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

  // ---- Sections ----------------------------------------------------------

  Widget _header() {
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
          ClipOval(
            child: SizedBox(
              width: 40,
              height: 40,
              child: NetworkImageWithFallback(
                url: MockData.userAvatar,
                fallbackIcon: Icons.person,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                        MockData.deliveryArea,
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
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textPrimary,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Search for dishes',
                style: TextStyle(color: AppColors.hint, fontSize: 14),
              ),
            ),
            const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _promoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _promoController,
            itemCount: MockData.promos.length,
            onPageChanged: (i) => setState(() => _promoPage = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _PromoCard(promo: MockData.promos[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            MockData.promos.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _promoPage ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == _promoPage ? AppColors.copper : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
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
        Row(
          children: const [
            Text(
              'SORT BY',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.swap_vert, color: AppColors.textSecondary, size: 18),
          ],
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

  Widget _featuredRail() {
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        return SizedBox(
          height: 256,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: MockData.frequentOrders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final dish = MockData.frequentOrders[i];
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
    return SizedBox(
      height: 210,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.78,
        ),
        itemCount: MockData.categories.length,
        itemBuilder: (context, i) => _CategoryCircle(category: MockData.categories[i]),
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

/// A round category shortcut with its label.
class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({required this.category});

  final MenuCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: NetworkImageWithFallback(url: category.imageUrl),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
