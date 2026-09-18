import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../routes/app_routes.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/nutrition_badge.dart';
import '../../widgets/price_text.dart';

/// The Takeaway ordering menu: category tabs, dishes with +/- quantity controls,
/// search / cart header actions, and floating bottom basket bar.
class TakeawayMenuScreen extends StatefulWidget {
  const TakeawayMenuScreen({super.key});

  @override
  State<TakeawayMenuScreen> createState() => _TakeawayMenuScreenState();
}

class _TakeawayMenuScreenState extends State<TakeawayMenuScreen> {
  int _selectedTab = 0;
  final TakeawayController _ctrl = TakeawayController.instance;

  void _openProduct(Dish dish) {
    Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: dish);
  }

  Future<void> _onNext() async {
    if (_ctrl.isCartEmpty) return;
    try {
      await _ctrl.placeOrder();
      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Takeaway order placed successfully!',
          title: 'Order Confirmed',
        );
        Navigator.of(context).pushNamed(AppRoutes.takeawaySuccess);
      }
    } catch (e) {
      if (mounted) {
        AppBanner.showError(
          context,
          'Failed to place order: $e',
          title: 'Order Error',
        );
      }
    }
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
                    _categoryTabs(),
                    const SizedBox(height: 18),
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
          const Text(
            'Takeaway orders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.search),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: AppColors.textPrimary),
                onPressed: () {},
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
          ),
        ],
      ),
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
        const Row(
          children: [
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

  // ── Featured Rail ───────────────────────────────────────────────────────────

  Widget _featuredRail() {
    return SizedBox(
      height: 256,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.frequentOrders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final dish = MockData.frequentOrders[i];
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: MockData.combinationBreakfast.map((dish) {
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
    return SizedBox(
      height: 272,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.recommendedBreakfast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final dish = MockData.recommendedBreakfast[i];
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
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
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

// ── Takeaway List Tile (Combination Breakfast) ────────────────────────────────

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
                padding: const EdgeInsets.only(top: 12),
                child: ClipOval(
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: NetworkImageWithFallback(url: dish.imageUrl),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
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
  });

  final int itemCount;
  final VoidCallback onNext;

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
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
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
