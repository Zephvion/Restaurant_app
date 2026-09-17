import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/order_food/account_screen.dart';
import 'screens/order_food/billing_screen.dart';
import 'screens/order_food/cart_screen.dart';
import 'screens/order_food/food_home_screen.dart';
import 'screens/order_food/notifications_screen.dart';
import 'screens/order_food/order_food_intro_screen.dart';
import 'screens/order_food/order_success_screen.dart';
import 'screens/order_food/payment_methods_screen.dart';
import 'screens/order_food/payment_options_screen.dart';
import 'screens/order_food/previous_order_screen.dart';
import 'screens/order_food/product_detail_screen.dart';
import 'screens/order_food/search_screen.dart';
import 'screens/order_food/track_order_screen.dart';
import 'screens/reserve_table/reservation_booking_screen.dart';
import 'screens/reserve_table/reservation_success_screen.dart';
import 'screens/reserve_table/reserve_dashboard_screen.dart';
import 'screens/reserve_table/reserve_table_intro_screen.dart';
import 'screens/reserve_table/select_restaurant_screen.dart';
import 'screens/catering/catering_booking_screen.dart';
import 'screens/catering/catering_dashboard_screen.dart';
import 'screens/catering/catering_intro_screen.dart';
import 'screens/catering/catering_notice_screen.dart';
import 'screens/catering/catering_notify_screen.dart';
import 'screens/catering/catering_success_screen.dart';
import 'screens/reserve_table/table_picker_screen.dart';
import 'screens/food_planner/food_planner_calculator_screen.dart';
import 'screens/food_planner/food_planner_cart_screen.dart';
import 'screens/food_planner/food_planner_intro_screen.dart';
import 'screens/food_planner/food_planner_manage_payments_screen.dart';
import 'screens/food_planner/food_planner_menu_screen.dart';
import 'screens/food_planner/food_planner_order_history_screen.dart';
import 'screens/food_planner/food_planner_payment_screen.dart';
import 'screens/food_planner/food_planner_product_screen.dart';
import 'screens/food_planner/food_planner_shell_screen.dart';
import 'screens/food_planner/food_planner_slot_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/takeaway/select_takeaway_restaurant_screen.dart';
import 'screens/takeaway/takeaway_dashboard_screen.dart';
import 'screens/takeaway/takeaway_intro_screen.dart';
import 'screens/takeaway/takeaway_menu_screen.dart';
import 'screens/takeaway/takeaway_success_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

import 'services/auth_service.dart';
import 'services/firebase_initializer.dart';
import 'services/menu_service.dart';
import 'services/notification_service.dart';
import 'services/order_service.dart';
import 'services/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase and session/backend services
  await FirebaseInitializer.initialize();
  await SessionManager.instance.init();
  await AuthService.instance.init();
  await MenuService.instance.init();
  await OrderService.instance.init();
  await NotificationService.instance.init();

  runApp(const ParagonApp());
}

class ParagonApp extends StatelessWidget {
  const ParagonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PARAGON',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      routes: {
        // ── Onboarding & Auth ──────────────────────────────────────────────
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),

        // ── Home ──────────────────────────────────────────────────────────
        AppRoutes.home: (_) => const FoodHomeScreen(),

        // ── Order Food flow ───────────────────────────────────────────────
        AppRoutes.orderFood: (_) => const FoodHomeScreen(),
        AppRoutes.foodHome: (_) => const FoodHomeScreen(),
        AppRoutes.productDetail: (_) => const ProductDetailScreen(),
        AppRoutes.cart: (_) => const CartScreen(),
        AppRoutes.billing: (_) => const BillingScreen(),
        AppRoutes.paymentMethods: (_) => const PaymentMethodsScreen(),
        AppRoutes.paymentOptions: (_) => const PaymentOptionsScreen(),
        AppRoutes.orderSuccess: (_) => const OrderSuccessScreen(),
        AppRoutes.trackOrder: (_) => const TrackOrderScreen(),
        AppRoutes.search: (_) => const SearchScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.previousOrder: (_) => const PreviousOrderScreen(),
        AppRoutes.account: (_) => const AccountScreen(),

        // ── Reserve Table flow ─────────────────────────────────────────────
        AppRoutes.reserveTable: (_) => const ReserveDashboardScreen(),
        AppRoutes.reserveDashboard: (_) => const ReserveDashboardScreen(),
        AppRoutes.selectRestaurant: (_) => const SelectRestaurantScreen(),
        AppRoutes.reservationBooking: (_) => const ReservationBookingScreen(),
        AppRoutes.tablePicker: (_) => const TablePickerScreen(),
        AppRoutes.reservationSuccess: (_) => const ReservationSuccessScreen(),

        // ── Take Away flow ─────────────────────────────────────────────────
        AppRoutes.takeaway: (_) => const TakeawayDashboardScreen(),
        AppRoutes.takeawayDashboard: (_) => const TakeawayDashboardScreen(),
        AppRoutes.takeawaySelectRestaurant: (_) =>
            const SelectTakeawayRestaurantScreen(),
        AppRoutes.takeawayMenu: (_) => const TakeawayMenuScreen(),
        AppRoutes.takeawaySuccess: (_) => const TakeawaySuccessScreen(),

        // ── Catering flow ──────────────────────────────────────────────────
        AppRoutes.catering: (_) => const CateringDashboardScreen(),
        AppRoutes.cateringDashboard: (_) => const CateringDashboardScreen(),
        AppRoutes.cateringNotice: (_) => const CateringNoticeScreen(),
        AppRoutes.cateringBooking: (_) => const CateringBookingScreen(),
        AppRoutes.cateringNotify: (_) => const CateringNotifyScreen(),
        AppRoutes.cateringSuccess: (_) => const CateringSuccessScreen(),

        // ── Food Planner flow ──────────────────────────────────────────────
        AppRoutes.foodPlannerIntro: (_) => const FoodPlannerShellScreen(),
        AppRoutes.foodPlanner: (_) => const FoodPlannerShellScreen(),
        AppRoutes.foodPlannerSlot: (_) => const FoodPlannerSlotScreen(),
        AppRoutes.foodPlannerMenu: (_) => const FoodPlannerMenuScreen(),
        AppRoutes.foodPlannerProduct: (_) => const FoodPlannerProductScreen(),
        AppRoutes.foodPlannerCart: (_) => const FoodPlannerCartScreen(),
        AppRoutes.foodPlannerPayment: (_) => const FoodPlannerPaymentScreen(),
        AppRoutes.foodPlannerCalculator: (_) =>
            const FoodPlannerCalculatorScreen(),
        AppRoutes.foodPlannerOrderHistory: (_) =>
            const FoodPlannerOrderHistoryScreen(),
        AppRoutes.foodPlannerManagePayments: (_) =>
            const FoodPlannerManagePaymentsScreen(),
      },
    );
  }
}
