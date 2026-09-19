import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/service_item.dart';
import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/basket_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/top_mode_selector.dart';

// ─── Tab model ───────────────────────────────────────────────────────────────

class _ServiceTab {
  const _ServiceTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });
  final String id;
  final String label;
  final IconData icon;
  final String route;
}

const _tabs = [
  _ServiceTab(
    id: 'order_food',
    label: 'Order Food',
    icon: Icons.lunch_dining_rounded,
    route: AppRoutes.foodHome,
  ),
  _ServiceTab(
    id: 'take_away',
    label: 'Take Away',
    icon: Icons.shopping_bag_rounded,
    route: AppRoutes.takeawayDashboard,
  ),
  _ServiceTab(
    id: 'reserve_table',
    label: 'Reserve Table',
    icon: Icons.table_restaurant_rounded,
    route: AppRoutes.reserveDashboard,
  ),
  _ServiceTab(
    id: 'catering',
    label: 'Catering',
    icon: Icons.room_service_rounded,
    route: AppRoutes.cateringDashboard,
  ),
  _ServiceTab(
    id: 'food_planner',
    label: 'Food Planner',
    icon: Icons.calendar_month_rounded,
    route: AppRoutes.foodPlanner,
  ),
];

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          final cart = CartController.instance;
          if (cart.isEmpty) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: BasketBar(
                itemCount: cart.totalQuantity,
                label: 'VIEW CART',
                onNext: () => Navigator.of(context).pushNamed(
                  AppRoutes.cart,
                  arguments: const {'isGlobal': true},
                ),
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top App Header with Brand & Cart ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 14, 4),
              child: Row(
                children: [
                  const Text(
                    'PARAGON',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Spacer(),
                  // Notifications bell
                  ListenableBuilder(
                    listenable: NotificationService.instance,
                    builder: (context, _) {
                      final unread = NotificationService.instance.unreadCount;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushNamed(AppRoutes.notifications),
                          ),
                          if (unread > 0)
                            Positioned(
                              top: 8,
                              right: 8,
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
                      );
                    },
                  ),
                  // Cart button
                  ListenableBuilder(
                    listenable: CartController.instance,
                    builder: (context, _) {
                      final count = CartController.instance.totalQuantity;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                            onPressed: () =>
                                Navigator.of(context).pushNamed(
                              AppRoutes.cart,
                              arguments: const {'isGlobal': true},
                            ),
                          ),
                          if (count > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
            ),
            // ── Swiggy-style organic flared top mode selector ───────────────
            TopModeSelector(
              controller: _tabController,
              backgroundColor: AppColors.background,
              canvasColor: AppColors.background,
            ),
            // ── Tab body ────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  return _ServicePage(
                    tab: tab,
                    onEnter: () => _navigate(tab.route),
                  );
                }).toList(),
              ),
            ),
            // ── Red accent bar ──────────────────────────────────────────────
            Container(height: 6, color: AppColors.accentRed),
          ],
        ),
      ),
    );
  }
}


// ─── Per-service full-page panel ──────────────────────────────────────────────

class _ServicePage extends StatelessWidget {
  const _ServicePage({required this.tab, required this.onEnter});
  final _ServiceTab tab;
  final VoidCallback onEnter;

  // Map tab id → hero image from the existing MockData services list
  static String _imageFor(String id) {
    try {
      return MockData.services.firstWhere((s) => s.id == id).imageUrl;
    } catch (_) {
      return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=75';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = _imageFor(tab.id);
    return GestureDetector(
      onTap: onEnter,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero background photo
          NetworkImageWithFallback(url: imgUrl, fit: BoxFit.cover),

          // Dark gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000),
                  Color(0xBB000000),
                ],
                stops: [0.3, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(tab.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  tab.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _subtitleFor(tab.id),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // CTA button
                ElevatedButton(
                  onPressed: onEnter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.6,
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_ctaFor(tab.id)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitleFor(String id) => switch (id) {
        'order_food' =>
          'Fresh meals delivered hot to your doorstep. Browse our menu and order now.',
        'take_away' =>
          'Skip the wait — pick up your favourite dishes ready to go.',
        'reserve_table' =>
          'Book your perfect table in seconds and enjoy a great dining experience.',
        'food_planner' =>
          'Plan your weekly meals in advance and let us take care of the rest.',
        'catering' =>
          'Premium catering for events, parties, and corporate gatherings.',
        _ => 'Tap to explore this service.',
      };

  static String _ctaFor(String id) => switch (id) {
        'order_food' => 'Order Now',
        'take_away' => 'Pick Up Now',
        'reserve_table' => 'Reserve Now',
        'food_planner' => 'Plan Meals',
        'catering' => 'Book Catering',
        _ => 'Get Started',
      };
}

// ─── Legacy ServiceCard (kept for any other screens that import it) ───────────

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.item,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final ServiceItem item;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkImageWithFallback(url: item.imageUrl),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height * 0.42,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC3A0C0D),
                        AppColors.maroon,
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.86),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              if (item.badgeCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _Badge(count: item.badgeCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accentRed,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
