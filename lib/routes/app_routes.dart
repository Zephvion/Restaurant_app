/// Centralized route names for the app's navigation flow.
///
/// The route *table* (which name maps to which screen) lives in `main.dart`;
/// these constants are the single source of truth for the names themselves.
class AppRoutes {
  AppRoutes._();

  // Set 1 — onboarding & auth.
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String home = '/home';

  // Order Food flow.
  static const String orderFood = '/order-food'; // full-bleed intro
  static const String foodHome = '/food-home'; // main menu
  static const String productDetail = '/product'; // arg: Dish
  static const String cart = '/cart';
  static const String billing = '/billing';
  static const String paymentMethods = '/payment-methods';
  static const String paymentOptions = '/payment-options';
  static const String orderSuccess = '/order-success';
  static const String trackOrder = '/track-order';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String previousOrder = '/previous-order';
  static const String account = '/account';

  // Reserve Table flow.
  static const String reserveTable = '/reserve-table';
  static const String reserveDashboard = '/reserve-dashboard';
  static const String selectRestaurant = '/select-restaurant';
  static const String reservationBooking = '/reservation-booking';
  static const String tablePicker = '/table-picker';
  static const String reservationSuccess = '/reservation-success';

  // Take Away flow.
  static const String takeaway = '/takeaway';
  static const String takeawayDashboard = '/takeaway-dashboard';
  static const String takeawaySelectRestaurant = '/takeaway-select-restaurant';
  static const String takeawayMenu = '/takeaway-menu';
  static const String takeawaySuccess = '/takeaway-success';

  // Catering flow.
  static const String catering = '/catering';
  static const String cateringDashboard = '/catering-dashboard';
  static const String cateringNotice = '/catering-notice';
  static const String cateringBooking = '/catering-booking';
  static const String cateringNotify = '/catering-notify';
  static const String cateringSuccess = '/catering-success';

  // Food Planner flow.
  static const String foodPlannerIntro = '/food-planner-intro';
  static const String foodPlanner = '/food-planner';
  static const String foodPlannerSlot = '/food-planner/slot';
  static const String foodPlannerMenu = '/food-planner/menu';
  static const String foodPlannerProduct = '/food-planner/product';
  static const String foodPlannerCart = '/food-planner/cart';
  static const String foodPlannerPayment = '/food-planner/payment';
  static const String foodPlannerCalculator = '/food-planner/calculator';
  static const String foodPlannerOrderHistory = '/food-planner/order-history';
  static const String foodPlannerManagePayments = '/food-planner/manage-payments';
}
