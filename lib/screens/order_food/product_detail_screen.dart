import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/price_text.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/veg_indicator.dart';

/// Product detail screen: hero photo, rating, price, description, nutrition
/// pills, ingredients, storage terms and reviews. The bottom bar switches from
/// "ADD TO CART" to a quantity stepper + NEXT once the dish is in the basket.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final Dish dish = arg is Dish ? arg : MockData.plainDosa;
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: _CircleIcon(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              _CircleIcon(
                icon: Icons.search,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
              ),
              AnimatedBuilder(
                animation: cart,
                builder: (context, _) => _CircleIcon(
                  icon: Icons.shopping_cart_outlined,
                  badge: cart.totalQuantity,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.cart),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.elliptical(200, 45),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.elliptical(200, 45),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkImageWithFallback(url: dish.imageUrl),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.45),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
              child: _Details(dish: dish),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(dish: dish),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            VegIndicator(isVeg: dish.isVeg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dish.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _RatingPill(rating: dish.rating),
          ],
        ),
        const SizedBox(height: 14),
        PriceText(price: dish.price, oldPrice: dish.oldPrice, size: 24),
        const SizedBox(height: 16),
        Text(dish.description,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 22),
        _NutritionRow(dish: dish),
        const SizedBox(height: 26),
        if (dish.ingredients.isNotEmpty) ...[
          _heading(context, "What's inside"),
          const SizedBox(height: 12),
          for (final item in dish.ingredients) _Bullet(text: item),
          const SizedBox(height: 22),
        ],
        _heading(context, 'Terms & Conditions of storage'),
        const SizedBox(height: 10),
        Text(
          'Best enjoyed fresh and immediately on delivery. If storage is '
          'necessary, refrigerate within two hours and consume within 24 '
          'hours. Reheat thoroughly before serving. PARAGON is not liable for '
          'quality once the item has left the kitchen beyond these guidelines.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

      ],
    );
  }

  Widget _heading(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final pills = [
      _NutriPill(value: '${dish.carbs}g', label: 'Carbs'),
      _NutriPill(value: '${dish.kcal}', label: 'Energy'),
      _NutriPill(value: '${dish.fat}g', label: 'Fat'),
      _NutriPill(value: '${dish.protein}g', label: 'Protein'),
    ];
    return Row(
      children: [
        for (var i = 0; i < pills.length; i++) ...[
          Expanded(child: pills[i]),
          if (i != pills.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _NutriPill extends StatelessWidget {
  const _NutriPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.copper,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7, right: 10),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.copper,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFFF5B942), size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap, this.badge = 0});

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                if (badge > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints:
                          const BoxConstraints(minWidth: 15, minHeight: 15),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom action bar — ADD TO CART, or a stepper + NEXT once in the basket.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final qty = cart.quantityOf(dish);
        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
          child: SafeArea(
            top: false,
            child: qty == 0
                ? _AddToCartButton(onTap: () => cart.add(dish))
                : Row(
                    children: [
                      QuantityStepper(
                        quantity: qty,
                        size: 38,
                        onIncrement: () => cart.increment(dish),
                        onDecrement: () => cart.decrement(dish),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NextButton(
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.cart),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Center(
            child: Text(
              'ADD TO CART',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: AppColors.copper,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Center(
            child: Text(
              'NEXT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
