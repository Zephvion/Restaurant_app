import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/service_tab_bar.dart';

/// Full-bleed "CATERING" intro screen — tap anywhere to proceed to the
/// Catering Dashboard.
class CateringIntroScreen extends StatefulWidget {
  const CateringIntroScreen({super.key});

  @override
  State<CateringIntroScreen> createState() => _CateringIntroScreenState();
}

class _CateringIntroScreenState extends State<CateringIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chevronCtrl;
  late final Animation<double> _chevronAnim;

  @override
  void initState() {
    super.initState();
    _chevronCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _chevronAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _chevronCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chevronCtrl.dispose();
    super.dispose();
  }

  void _proceed() =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.cateringDashboard);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _proceed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --- full-bleed hero ---
            const NetworkImageWithFallback(
              url: MockData.cateringHero,
              fit: BoxFit.cover,
              fallbackIcon: Icons.room_service,
            ),
            // --- dark gradient at the bottom ---
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // --- service tab switcher (top) ---
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ServiceTabBar(activeId: 'catering'),
            ),
            // --- text + chevron ---
            Positioned(
              left: 28,
              right: 28,
              bottom: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CATERING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Book for catering orders with Paragon group',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: AnimatedBuilder(
                      animation: _chevronAnim,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _chevronAnim.value),
                        child: const Column(
                          children: [
                            Icon(Icons.expand_more,
                                color: Colors.white70, size: 28),
                            Icon(Icons.expand_more,
                                color: Colors.white38, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
