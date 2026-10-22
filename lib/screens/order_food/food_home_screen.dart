import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/menu_category.dart';
import '../../models/promo_banner.dart';
import '../../routes/app_routes.dart';
import '../../services/favorites_service.dart';
import '../../services/menu_service.dart';
import '../../services/smart_recommendation_service.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/basket_bar.dart';
import '../../widgets/coupon_sheet.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/main_top_header.dart';
import '../../widgets/menu_list_tile.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';
import '../../widgets/themed_page_background.dart';

/// The main "Order Food" menu: interactive delivery header, search, promo carousel,
/// category tabs with dynamic filtering, sort options, clickable categories and dish rails.
class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PageController _promoController = PageController(viewportFraction: 0.9);
  Timer? _promoTimer;
  int _selectedTab = 0;
  int _promoPage = 0;
  bool _promoForward = true;
  String _activeCategoryFilter = 'All';

  final CartController _cart = CartController.instance;
  List<Dish> get _dishes => MenuService.instance.dishes;

  @override
  void initState() {
    super.initState();
    _startPromoTimer();
  }

  void _startPromoTimer() {
    _promoTimer?.cancel();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_promoController.hasClients) return;
      final total = MockData.promos.length;
      if (total <= 1) return;

      int nextPage;
      if (_promoForward) {
        if (_promoPage >= total - 1) {
          _promoForward = false;
          nextPage = _promoPage - 1;
        } else {
          nextPage = _promoPage + 1;
        }
      } else {
        if (_promoPage <= 0) {
          _promoForward = true;
          nextPage = _promoPage + 1;
        } else {
          nextPage = _promoPage - 1;
        }
      }

      nextPage = nextPage.clamp(0, total - 1);
      _promoController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  void _openProduct(Dish dish) {
    FavoritesService.instance.trackViewed(dish.id);
    Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: dish);
  }

  void _openCategory(String category) {
    Navigator.of(context).pushNamed(
      AppRoutes.categoryListing,
      arguments: category,
    );
  }

  void _add(Dish dish) => _cart.add(dish);

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
    super.build(context);
    final filteredDishes = _applyFiltersAndSort(_dishes);

    final listContent = ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (!widget.isEmbedded) ...[
          const MainTopHeader(accentColor: Color(0xFFFF4B4B)),
          const SizedBox(height: 10),
          const DashboardTabBar(activeId: 'order_food'),
          const SizedBox(height: 12),
        ] else ...[
          const SizedBox(height: 12),
        ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader('Recommended for You'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 12, color: AppColors.accentRed),
                          SizedBox(width: 4),
                          Text(
                            'Personalized',
                            style: TextStyle(
                              color: AppColors.accentRed,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _recommendedRail(),
            ],
          );

    final centeredContent = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: listContent,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.isEmbedded
          ? centeredContent
          : ThemedPageBackground(
              accentColor: const Color(0xFFFF4B4B),
              child: SafeArea(
                bottom: false,
                child: centeredContent,
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
    return SizedBox(
      height: 154,
      child: PageView.builder(
        controller: _promoController,
        itemCount: MockData.promos.length,
        onPageChanged: (i) {
          if (i >= MockData.promos.length - 1) {
            _promoForward = false;
          } else if (i <= 0) {
            _promoForward = true;
          }
          _promoPage = i;
          _startPromoTimer();
        },
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _PromoCard(promo: MockData.promos[i]),
          );
        },
      ),
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
                if (_selectedTab == i && i != 0) {
                  _selectedTab = 0;
                  _activeCategoryFilter = 'All';
                } else {
                  _selectedTab = i;
                  _activeCategoryFilter = i == 0 ? 'All' : tabName;
                }
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
        final screenWidth = MediaQuery.sizeOf(context).width;
        final cardWidth = screenWidth < 460
            ? ((screenWidth - 40 - 14) / 2).floorToDouble()
            : 180.0;

        return SizedBox(
          height: 242,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dishes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final dish = dishes[i];
              return FeaturedDishCard(
                dish: dish,
                width: cardWidth,
                quantity: _cart.quantityOf(dish),
                inCart: _cart.contains(dish),
                onTap: () => _openProduct(dish),
                onAdd: () => _add(dish),
                onIncrement: () => _cart.increment(dish),
                onDecrement: () => _cart.decrement(dish),
              );
            },
          ),
        );
      },
    );
  }

  Widget _categoryCircles() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final cat = MockData.categories[i];
          return SizedBox(
            width: 72,
            child: _CategoryCircle(
              category: cat,
              onTap: () => _openCategory(cat.name),
            ),
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
                    quantity: _cart.quantityOf(dish),
                    inCart: _cart.contains(dish),
                    onTap: () => _openProduct(dish),
                    onAdd: () => _add(dish),
                    onIncrement: () => _cart.increment(dish),
                    onDecrement: () => _cart.decrement(dish),
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
      animation: Listenable.merge([_cart, FavoritesService.instance]),
      builder: (context, _) {
        final dishes = SmartRecommendationService.instance.getCuratedFeedDishes(limit: 8);
        final screenWidth = MediaQuery.sizeOf(context).width;
        final cardWidth = screenWidth < 460
            ? ((screenWidth - 40 - 14) / 2).floorToDouble()
            : 180.0;

        return SizedBox(
          height: 242,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dishes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final dish = dishes[i];
              return RecommendedDishCard(
                dish: dish,
                width: cardWidth,
                quantity: _cart.quantityOf(dish),
                inCart: _cart.contains(dish),
                onTap: () => _openProduct(dish),
                onAdd: () => _add(dish),
                onIncrement: () => _cart.increment(dish),
                onDecrement: () => _cart.decrement(dish),
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

/// A single promo card in the carousel matching the highlighted offer cards,
/// blending seamlessly into the dark page background while showcasing authentic restaurant offers.
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final PromoBanner promo;

  @override
  Widget build(BuildContext context) {
    final gradient = promo.gradientColors ??
        [
          const Color(0xFF0C241E),
          const Color(0xFF091814),
          AppColors.background,
        ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => CouponSheet.show(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradient,
              stops: const [0.0, 0.55, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Subtle background spotlight glow behind food plate
              Positioned(
                right: 15,
                top: 10,
                bottom: 10,
                width: 145,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (promo.accentColor ?? AppColors.copper)
                            .withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // The food dish on the right with a soft shader mask blending into the dark card
              Positioned(
                right: -8,
                top: -6,
                bottom: -6,
                width: 165,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      stops: [0.0, 0.3],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    promo.imageUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                    errorBuilder: (_, __, ___) =>
                        NetworkImageWithFallback(url: promo.imageUrl),
                  ),
                ),
              ),

              // Brand badge for Nandhana/Palace style in top right corner
              if (promo.style == PromoBannerStyle.palace)
                Positioned(
                  right: 14,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'PARAGON',
                      style: TextStyle(
                        color: Color(0xFFF25A50),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

              // Left side offer content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxTextWidth =
                        (constraints.maxWidth - 120).clamp(140.0, 240.0);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: maxTextWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Top brand header
                            _buildTopHeader(promo),
                            const SizedBox(height: 5),

                            // 2. Bold headline offer
                            Text(
                              promo.headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _getHeadlineColor(promo),
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // 3. Subtitle with code / details
                            Text(
                              promo.displaySubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 4. "ORDER NOW" Pill button
                            _buildButton(promo),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(PromoBanner promo) {
    switch (promo.style) {
      case PromoBannerStyle.gourmet:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'gourmet',
              style: TextStyle(
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE5C580),
              ),
            ),
            SizedBox(width: 5),
            Text(
              'FOOD FESTIVAL',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFFE5C580),
              ),
            ),
          ],
        );
      case PromoBannerStyle.healthy:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF145432),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.eco_rounded, size: 10, color: Color(0xFF7DE8AC)),
              SizedBox(width: 4),
              Text(
                'HIGH FIBRE',
                style: TextStyle(
                  color: Color(0xFF7DE8AC),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      case PromoBannerStyle.palace:
        return Text(
          promo.tag,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        );
    }
  }

  Color _getHeadlineColor(PromoBanner promo) {
    switch (promo.style) {
      case PromoBannerStyle.gourmet:
        return const Color(0xFFE5C580);
      case PromoBannerStyle.healthy:
        return Colors.white;
      case PromoBannerStyle.palace:
        return const Color(0xFFF25A50);
    }
  }

  Widget _buildButton(PromoBanner promo) {
    switch (promo.style) {
      case PromoBannerStyle.gourmet:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8C882), Color(0xFFD4A750)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A750).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'ORDER NOW',
            style: TextStyle(
              color: Colors.black,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        );
      case PromoBannerStyle.healthy:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'ORDER NOW',
            style: TextStyle(
              color: Color(0xFF0D3B23),
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        );
      case PromoBannerStyle.palace:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B1E22),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B1E22).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'ORDER NOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        );
    }
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
