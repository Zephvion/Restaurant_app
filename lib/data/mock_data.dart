import '../models/address.dart';
import '../models/app_notification.dart';
import '../models/dish.dart';
import '../models/menu_category.dart';
import '../models/onboarding_item.dart';
import '../models/payment_method.dart';
import '../models/promo_banner.dart';
import '../models/restaurant.dart';
import '../models/service_item.dart';
import '../routes/app_routes.dart';

/// In-app mock data (frontend-only build — no backend).
///
/// Photos are pulled from Unsplash's image CDN. If a device is offline, the
/// [NetworkImageWithFallback] widget shows a themed placeholder instead.
class MockData {
  MockData._();

  // ---- Profile -----------------------------------------------------------

  /// Phone number shown on the OTP screen (matches the Figma).
  static const String demoPhoneNumber = '+91 9874563210';

  static const String userName = 'Arti Abraham';
  static const String userPhone = '+91 9874563210';
  static const String userEmail = 'artiabraham123@gmail.com';
  static const String userAvatar =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=70';

  /// Delivery area shown in the home header ("Deliver to …").
  static const String deliveryArea = 'Palazhi , Calicut';

  // Order / delivery constants used on the tracking & notification screens.
  static const String orderId = 'PO78965412';
  static const String deliveryPartnerName = 'John Doe';
  static const String deliveryPartnerPhone = '+91 987654321';

  // ---- Onboarding & services (Set 1) ------------------------------------

  /// The three onboarding slides.
  static const List<OnboardingItem> onboarding = [
    OnboardingItem(
      title: 'Place catering Orders',
      subtitle: 'Place catering orders with us',
      frontImage:
          'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=800&q=70',
      backImage:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=70',
    ),
    OnboardingItem(
      title: 'Reserve a table',
      subtitle: 'Tired of having to wait ? Make a  table reservation right away.',
      frontImage:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=70',
      backImage:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=800&q=70',
    ),
    OnboardingItem(
      title: 'Plan your weekly menu',
      subtitle:
          "You can order weekly meals, and we'll bring them straight to your door.",
      frontImage:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=70',
      backImage:
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=800&q=70',
    ),
  ];

  /// The five services on the home screen.
  static const List<ServiceItem> services = [
    ServiceItem(
      id: 'order_food',
      title: 'ORDER FOOD',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=70',
      route: AppRoutes.orderFood,
    ),
    ServiceItem(
      id: 'take_away',
      title: 'TAKE AWAY',
      imageUrl:
          'https://images.unsplash.com/photo-1526367790999-0150786686a2?auto=format&fit=crop&w=600&q=70',
      route: AppRoutes.takeaway,
    ),
    ServiceItem(
      id: 'reserve_table',
      title: 'RESERVE TABLE',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=600&q=70',
      route: AppRoutes.reserveTable,
    ),
    ServiceItem(
      id: 'food_planner',
      title: 'FOOD PLANNER',
      imageUrl:
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=600&q=70',
      badgeCount: 1,
      route: AppRoutes.foodPlannerIntro,
    ),
    ServiceItem(
      id: 'catering',
      title: 'CATERING',
      imageUrl:
          'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=70',
      route: AppRoutes.catering,
    ),
  ];

  // ---- Order Food: hero image + promos ----------------------------------

  /// Full-bleed image on the "ORDER FOOD" intro screen.
  static const String orderFoodHero =
      'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=1000&q=75';

  static const List<PromoBanner> promos = [
    PromoBanner(
      headline: 'GET 10% OFF',
      code: 'WELCOMEBACK',
      imageUrl: 'assets/images/order/extracted/promo_banner_1.webp',
    ),
    PromoBanner(
      headline: 'FREE DELIVERY',
      code: 'FREESHIP',
      imageUrl: 'assets/images/order/extracted/promo_banner_1.webp',
    ),
    PromoBanner(
      headline: 'FLAT ₹50 OFF',
      code: 'PARAGON50',
      imageUrl: 'assets/images/order/extracted/promo_banner_1.webp',
    ),
  ];

  static const List<PromoBanner> promoBanners = promos;

  // ---- Menu category tabs & circles -------------------------------------

  /// The scrollable tab row under "MENU".
  static const List<String> categoryTabs = [
    'Frequent order',
    'Veg',
    'Fish',
    'Egg',
    'Chicken',
    'Breakfast',
  ];

  /// The round category shortcuts below the featured dishes.
  static const List<MenuCategory> categories = [
    MenuCategory(
      name: 'Meals',
      imageUrl: 'assets/images/order/extracted/cat_meals_1.webp',
    ),
    MenuCategory(
      name: 'Chicken',
      imageUrl: 'assets/images/order/extracted/cat_chicken.webp',
    ),
    MenuCategory(
      name: 'Biriyani',
      imageUrl: 'assets/images/order/extracted/cat_biryani_1.webp',
    ),
    MenuCategory(
      name: 'Breakfast',
      imageUrl: 'assets/images/order/extracted/cat_breakfast.webp',
    ),
    MenuCategory(
      name: 'Fish',
      imageUrl: 'assets/images/order/extracted/cat_fish.webp',
    ),
    MenuCategory(
      name: 'Biriyani',
      imageUrl: 'assets/images/order/extracted/cat_biryani_2.webp',
    ),
    MenuCategory(
      name: 'Veg Rice',
      imageUrl: 'assets/images/order/extracted/cat_veg_rice.webp',
    ),
    MenuCategory(
      name: 'Meals',
      imageUrl: 'assets/images/order/extracted/cat_meals_2.webp',
    ),
  ];

  // ---- Dishes ------------------------------------------------------------

  /// The hero dish used on the product detail screen (and reused elsewhere).
  static const Dish plainDosa = Dish(
    id: 'plain_dosa',
    name: 'Plain Dosa',
    price: 80,
    oldPrice: 100,
    imageUrl: 'assets/images/order/extracted/featured_dosa.webp',
    kcal: 320,
    grams: 300,
    isVeg: true,
    rating: 4.7,
    category: 'Frequent order',
    description:
        'A crisp, golden crepe made from a naturally fermented rice-and-lentil '
        'batter. Light, lacy and served piping hot with coconut chutney and a '
        'bowl of sambar.',
    ingredients: [
      'Par-boiled rice & urad dal, stone-ground and fermented overnight',
      'A pinch of fenugreek and rock salt',
      'Cooked on a seasoned griddle with a touch of gingelly oil',
      'Served with coconut chutney and sambar',
    ],
    carbs: 45,
    fat: 12,
    protein: 8,
  );

  static const Dish kuzhipaniyaram = Dish(
    id: 'kuzhipaniyaram',
    name: 'Kuzhipaniyaram',
    price: 80,
    imageUrl: 'assets/images/order/extracted/featured_kuzhi.webp',
    kcal: 320,
    grams: 300,
    isVeg: true,
    rating: 4.6,
    category: 'Frequent order',
    description:
        'Soft, fluffy dumplings with crisp golden shells, made from a lightly '
        'spiced dosa batter and pan-fried in a special dimpled skillet.',
    ingredients: [
      'Fermented rice & lentil batter',
      'Tempered mustard, curry leaves and onion',
      'Pan-fried in a paniyaram skillet',
    ],
    carbs: 40,
    fat: 10,
    protein: 7,
  );

  static const Dish meals = Dish(
    id: 'meals',
    name: 'Meals',
    price: 80,
    imageUrl: 'assets/images/foodplanner/extracted/card_meals.webp',
    kcal: 620,
    grams: 550,
    isVeg: true,
    rating: 4.8,
    category: 'Meals',
    description:
        'A traditional Kerala sadya-style plate — rice with an assortment of '
        'curries, pickles, thoran and payasam served on a banana leaf.',
    ingredients: [
        'Steamed matta rice',
        'Sambar, avial, thoran and pickle',
        'Papadam and a sweet payasam',
    ],
    carbs: 90,
    fat: 18,
    protein: 15,
  );

  static const Dish freshJuiceOrange = Dish(
    id: 'orange_juice',
    name: 'Fresh Juice - Orange',
    price: 110,
    imageUrl:
        'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=600&q=70',
    kcal: 110,
    grams: 250,
    isVeg: true,
    rating: 4.5,
    category: 'Beverages',
    description:
        'Freshly squeezed oranges, served chilled with no added sugar.',
    ingredients: ['Hand-pressed Nagpur oranges', 'A pinch of black salt'],
    carbs: 26,
    fat: 0,
    protein: 2,
  );

  /// Horizontal "Frequent order" cards at the top of the menu.
  static const List<Dish> frequentOrders = [
    plainDosa,
    kuzhipaniyaram,
    meals,
  ];

  /// The "Combination Breakfast" list.
  static const List<Dish> combinationBreakfast = [
    Dish(
      id: 'appam_stew',
      name: 'Appam & Stew',
      subtitle: '2 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/thumb_appam.webp',
      category: 'Breakfast',
      description:
          'Soft, lacy appams with a fluffy centre served with a fragrant, '
          'coconut-milk vegetable stew.',
      ingredients: [
        'Fermented rice & coconut batter appams',
        'Vegetable stew simmered in coconut milk',
      ],
    ),
    Dish(
      id: 'idiyappam_kadala',
      name: 'Idiyappam & Kadala curry',
      subtitle: '4 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/thumb_idiyappam.webp',
      category: 'Breakfast',
      description:
          'Delicate steamed rice-flour string hoppers paired with a spiced '
          'black chickpea curry.',
      ingredients: [
        'Steamed rice-flour idiyappam',
        'Black chana in a roasted-coconut gravy',
      ],
    ),
    Dish(
      id: 'puttu_kadala',
      name: 'Puttu & Kadala curry',
      subtitle: '2 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/thumb_puttu.webp',
      category: 'Breakfast',
      description:
          'Steamed cylinders of ground rice and coconut served with a hearty '
          'black chickpea curry.',
      ingredients: ['Rice flour & grated coconut puttu', 'Kadala curry'],
    ),
    Dish(
      id: 'poori_masala',
      name: 'Poori Masala',
      subtitle: '2 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/thumb_poori.webp',
      category: 'Breakfast',
      description:
          'Puffy deep-fried pooris with a mildly spiced potato masala.',
      ingredients: ['Whole-wheat pooris', 'Turmeric potato masala'],
    ),
    Dish(
      id: 'idli_sambar',
      name: 'Idli & Sambar',
      subtitle: '4 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/thumb_idli.webp',
      category: 'Breakfast',
      description:
          'Steamed, pillowy rice cakes served with lentil sambar and chutney.',
      ingredients: ['Steamed idli', 'Toor-dal sambar', 'Coconut chutney'],
    ),
  ];

  /// The "Recommended Breakfast" cards.
  static const List<Dish> recommendedBreakfast = [
    Dish(
      id: 'plain_dosa_2',
      name: 'Plain Dosa',
      subtitle: '2 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/rec_dosa.webp',
      category: 'Breakfast',
      description:
          'Two crisp golden dosas served with coconut chutney and sambar.',
      ingredients: ['Fermented rice & lentil batter', 'Chutney and sambar'],
    ),
    Dish(
      id: 'puttu_kadala_2',
      name: 'Puttu and Kadala',
      subtitle: '2 nos',
      price: 180,
      imageUrl: 'assets/images/order/extracted/rec_puttu.webp',
      category: 'Breakfast',
      description:
          'Steamed cylinders of ground rice and coconut served with kadala curry.',
      ingredients: ['Rice flour & grated coconut puttu', 'Kadala curry'],
    ),
  ];

  // ---- Category-specific dishes ------------------------------------------

  static const List<Dish> chickenDishes = [
    Dish(
      id: 'chicken_biriyani',
      name: 'Chicken Biriyani',
      price: 220,
      imageUrl: 'assets/images/order/extracted/cat_chicken.webp',
      kcal: 580,
      grams: 450,
      isVeg: false,
      rating: 4.8,
      category: 'Chicken',
      description: 'Fragrant basmati rice layered with tender, spice-marinated chicken pieces, slow-cooked in dum style.',
      ingredients: ['Basmati rice', 'Chicken marinated in yoghurt & spices', 'Saffron & fried onions'],
      carbs: 60,
      fat: 22,
      protein: 28,
    ),
    Dish(
      id: 'chicken_curry',
      name: 'Chicken Curry',
      price: 180,
      imageUrl: 'assets/images/order/extracted/cat_chicken.webp',
      kcal: 420,
      grams: 350,
      isVeg: false,
      rating: 4.6,
      category: 'Chicken',
      description: 'Tender chicken pieces simmered in a rich, aromatic gravy with Kerala spices.',
      ingredients: ['Chicken', 'Coconut milk gravy', 'Kerala spice blend'],
      carbs: 15,
      fat: 20,
      protein: 32,
    ),
  ];

  static const List<Dish> biriyaniDishes = [
    Dish(
      id: 'veg_biriyani',
      name: 'Veg Biriyani',
      price: 160,
      imageUrl: 'assets/images/order/extracted/cat_biryani_1.webp',
      kcal: 450,
      grams: 400,
      isVeg: true,
      rating: 4.5,
      category: 'Biriyani',
      description: 'Aromatic basmati rice with mixed vegetables, layered and slow-cooked with saffron.',
      ingredients: ['Basmati rice', 'Mixed vegetables', 'Saffron & whole spices'],
      carbs: 65,
      fat: 12,
      protein: 10,
    ),
    Dish(
      id: 'mutton_biriyani',
      name: 'Mutton Biriyani',
      price: 280,
      imageUrl: 'assets/images/order/extracted/cat_biryani_2.webp',
      kcal: 650,
      grams: 500,
      isVeg: false,
      rating: 4.9,
      category: 'Biriyani',
      description: 'Premium mutton pieces with fragrant rice, prepared in authentic Malabar style.',
      ingredients: ['Basmati rice', 'Tender mutton', 'Malabar spice blend & ghee'],
      carbs: 55,
      fat: 28,
      protein: 35,
    ),
  ];

  static const List<Dish> fishDishes = [
    Dish(
      id: 'fish_curry',
      name: 'Fish Curry',
      price: 200,
      imageUrl: 'assets/images/order/extracted/cat_fish.webp',
      kcal: 380,
      grams: 350,
      isVeg: false,
      rating: 4.7,
      category: 'Fish',
      description: 'Fresh fish in a tangy Kerala-style curry with raw mango and coconut.',
      ingredients: ['Fresh fish', 'Raw mango', 'Coconut & kokum gravy'],
      carbs: 12,
      fat: 18,
      protein: 30,
    ),
    Dish(
      id: 'fish_fry',
      name: 'Fish Fry',
      price: 220,
      imageUrl: 'assets/images/order/extracted/cat_fish.webp',
      kcal: 350,
      grams: 250,
      isVeg: false,
      rating: 4.8,
      category: 'Fish',
      description: 'Marinated fish fillet, shallow-fried to a crispy golden finish.',
      ingredients: ['Fish fillet', 'Chilli-turmeric marinade', 'Curry leaves & shallots'],
      carbs: 8,
      fat: 20,
      protein: 28,
    ),
  ];

  static const List<Dish> vegDishes = [
    Dish(
      id: 'chappathi',
      name: 'Chappathi',
      subtitle: '3 nos',
      price: 70,
      imageUrl: 'assets/images/foodplanner/extracted/card_chappathi.webp',
      kcal: 240,
      grams: 180,
      isVeg: true,
      rating: 4.6,
      category: 'Veg',
      description: 'Soft, layered whole-wheat chappathis served with veg kurma.',
      ingredients: ['Whole-wheat flour', 'Ghee', 'Veg kurma'],
      carbs: 38,
      fat: 6,
      protein: 7,
    ),
    Dish(
      id: 'avial',
      name: 'Avial',
      price: 120,
      imageUrl: 'assets/images/order/extracted/cat_veg_rice.webp',
      kcal: 280,
      grams: 300,
      isVeg: true,
      rating: 4.5,
      category: 'Veg',
      description: 'Mixed vegetables in a coconut-yoghurt sauce, a Kerala sadya staple.',
      ingredients: ['Mixed vegetables', 'Coconut paste', 'Yoghurt & curry leaves'],
      carbs: 30,
      fat: 14,
      protein: 6,
    ),
    Dish(
      id: 'sambar_rice',
      name: 'Sambar Rice',
      price: 100,
      imageUrl: 'assets/images/order/extracted/cat_veg_rice.webp',
      kcal: 380,
      grams: 400,
      isVeg: true,
      rating: 4.4,
      category: 'Veg',
      description: 'Hot steamed rice served with a generous helping of vegetable sambar.',
      ingredients: ['Steamed rice', 'Toor dal sambar', 'Mixed vegetables & tamarind'],
      carbs: 65,
      fat: 8,
      protein: 12,
    ),
  ];

  static const List<Dish> eggDishes = [
    Dish(
      id: 'egg_curry',
      name: 'Egg Curry',
      price: 120,
      imageUrl: 'assets/images/order/extracted/cat_meals_2.webp',
      kcal: 320,
      grams: 300,
      isVeg: false,
      rating: 4.5,
      category: 'Egg',
      description: 'Boiled eggs in a rich, spiced onion-tomato gravy.',
      ingredients: ['Boiled eggs', 'Onion-tomato gravy', 'Garam masala'],
      carbs: 12,
      fat: 18,
      protein: 16,
    ),
    Dish(
      id: 'egg_roast',
      name: 'Egg Roast',
      price: 140,
      imageUrl: 'assets/images/order/extracted/cat_meals_2.webp',
      kcal: 340,
      grams: 280,
      isVeg: false,
      rating: 4.6,
      category: 'Egg',
      description: 'Kerala-style egg roast with a thick, spicy masala coating.',
      ingredients: ['Eggs', 'Shallots & curry leaves', 'Kerala spice roast'],
      carbs: 10,
      fat: 20,
      protein: 18,
    ),
  ];

  static const List<Dish> mealsDishes = [
    Dish(
      id: 'veg_meals',
      name: 'Veg Meals',
      price: 130,
      imageUrl: 'assets/images/foodplanner/extracted/card_meals.webp',
      kcal: 620,
      grams: 550,
      isVeg: true,
      rating: 4.8,
      category: 'Meals',
      description:
          'A traditional Kerala sadya-style plate — rice with an assortment of '
          'curries, pickles, thoran and payasam served on a banana leaf.',
      ingredients: [
        'Steamed matta rice',
        'Sambar, avial, thoran and pickle',
        'Papadam and a sweet payasam',
      ],
      carbs: 90,
      fat: 18,
      protein: 15,
    ),
    Dish(
      id: 'non_veg_meals',
      name: 'Non-Veg Meals',
      price: 180,
      imageUrl: 'assets/images/foodplanner/extracted/card_meals.webp',
      kcal: 750,
      grams: 600,
      isVeg: false,
      rating: 4.8,
      category: 'Meals',
      description: 'Full non-veg thali with rice, chicken curry, fish fry, sambar and payasam.',
      ingredients: ['Steamed rice', 'Chicken curry & fish fry', 'Sambar, thoran & payasam'],
      carbs: 85,
      fat: 25,
      protein: 30,
    ),
  ];

  static const List<Dish> vegRiceDishes = [
    Dish(
      id: 'lemon_rice',
      name: 'Lemon Rice',
      price: 90,
      imageUrl: 'assets/images/order/extracted/cat_veg_rice.webp',
      kcal: 320,
      grams: 350,
      isVeg: true,
      rating: 4.3,
      category: 'Veg Rice',
      description: 'Tangy, tempered rice with lemon, peanuts and curry leaves.',
      ingredients: ['Steamed rice', 'Lemon juice & turmeric', 'Peanuts & curry leaves'],
      carbs: 55,
      fat: 8,
      protein: 6,
    ),
    Dish(
      id: 'ghee_rice',
      name: 'Ghee Rice',
      price: 110,
      imageUrl: 'assets/images/order/extracted/cat_veg_rice.webp',
      kcal: 400,
      grams: 380,
      isVeg: true,
      rating: 4.6,
      category: 'Veg Rice',
      description: 'Fragrant basmati rice cooked with pure ghee and whole spices.',
      ingredients: ['Basmati rice', 'Pure ghee', 'Cardamom, cloves & cinnamon'],
      carbs: 60,
      fat: 15,
      protein: 7,
    ),
  ];

  /// All dishes combined for easy lookup.
  static const List<Dish> dishes = [
    ...frequentOrders,
    ...combinationBreakfast,
    ...recommendedBreakfast,
    ...chickenDishes,
    ...biriyaniDishes,
    ...fishDishes,
    ...vegDishes,
    ...eggDishes,
    ...mealsDishes,
    ...vegRiceDishes,
  ];

  /// Helper to get all dishes belonging to a category without duplicating data.
  static List<Dish> getDishesForCategory(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.isEmpty || cat == 'all' || cat == 'frequent order') {
      return dishes;
    }
    return dishes.where((dish) {
      final dishCat = dish.category.toLowerCase().trim();
      if (dishCat == cat) return true;
      if (cat == 'veg' && dish.isVeg) return true;
      if (cat == 'breakfast' &&
          (dishCat == 'breakfast' ||
              dish.id == 'plain_dosa' ||
              dish.id == 'kuzhipaniyaram')) {
        return true;
      }
      if (cat == 'meals' && (dishCat == 'meals' || dish.id == 'meals')) {
        return true;
      }
      if (cat == 'biriyani' && dish.name.toLowerCase().contains('biriyani')) {
        return true;
      }
      if (cat == 'chicken' && dish.name.toLowerCase().contains('chicken')) {
        return true;
      }
      if (cat == 'fish' && dish.name.toLowerCase().contains('fish')) {
        return true;
      }
      if (cat == 'egg' && dish.name.toLowerCase().contains('egg')) {
        return true;
      }
      if (cat == 'veg rice' &&
          (dishCat == 'veg rice' || dish.name.toLowerCase().contains('rice'))) {
        return true;
      }
      return false;
    }).toList();
  }

  // ---- Addresses ---------------------------------------------------------

  static const List<Address> addresses = [
    Address(
      label: 'Home',
      details: 'Flat no 9B, Landmark World, Palazhi, Calicut, 673014',
      isDefault: true,
    ),
    Address(
      label: 'Office',
      details: 'Cybaze technologies, UL Cyberpark, Palazhi, Calicut, 6730',
    ),
  ];

  // ---- Payment methods ---------------------------------------------------

  static const List<PaymentMethod> cards = [
    PaymentMethod(
      id: 'card_axis',
      title: 'Mastercard  ....2453',
      subtitle: 'Axis Bank',
      kind: PaymentKind.card,
      assetKind: 'mastercard',
    ),
    PaymentMethod(
      id: 'card_hdfc',
      title: 'VISA  ....2453',
      subtitle: 'HDFC Bank',
      kind: PaymentKind.card,
      assetKind: 'visa',
    ),
  ];

  static const List<PaymentMethod> upi = [
    PaymentMethod(
      id: 'upi_gpay',
      title: 'Google Pay',
      kind: PaymentKind.upi,
      assetKind: 'gpay',
    ),
    PaymentMethod(
      id: 'upi_phonepe',
      title: 'PhonePe',
      kind: PaymentKind.upi,
      assetKind: 'phonepe',
    ),
    PaymentMethod(
      id: 'upi_id',
      title: 'artiabraham@oksbi',
      kind: PaymentKind.upi,
      assetKind: 'upi',
    ),
  ];

  static const PaymentMethod cashOnDelivery = PaymentMethod(
    id: 'cod',
    title: 'Cash on Delivery',
    kind: PaymentKind.cash,
    assetKind: 'cod',
  );

  /// Every selectable method (used by the cart controller default + options).
  static const List<PaymentMethod> paymentMethods = [
    ...cards,
    ...upi,
    cashOnDelivery,
  ];

  // ---- Notifications -----------------------------------------------------

  static const List<AppNotification> notifications = [
    AppNotification(
      title: 'Arriving Soon',
      orderId: orderId,
      imageUrl:
          'https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&fit=crop&w=200&q=70',
    ),
    AppNotification(
      title: 'Order Placed',
      orderId: orderId,
      isPlaced: true,
      imageUrl:
          'https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&fit=crop&w=200&q=70',
    ),
    AppNotification(
      title: 'Offer',
      isPromo: true,
      promoText: 'Get 30% off on orders above  500',
    ),
  ];
  // ---- Reserve Table -------------------------------------------------------

  /// Full-bleed restaurant photo on the Reserve Table intro screen.
  static const String reserveTableHero =
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1000&q=75';

  /// Smaller hero used inside the booking screen.
  static const String reserveTableInterior =
      'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=800&q=70';

  /// All Paragon restaurant branches grouped by city.
  static const List<Restaurant> restaurants = [
    // Calicut
    Restaurant(
      id: 'calicut_paragon',
      name: 'Paragon Restaurant',
      address: 'Kannur road, Near CH over bridge',
      city: 'Calicut',
    ),
    Restaurant(
      id: 'calicut_mgrill',
      name: 'M Grill - Paragon Group',
      address: 'Focus Mall, Rajaji Road',
      city: 'Calicut',
    ),
    Restaurant(
      id: 'calicut_browntown',
      name: 'Brown Town - Paragon Group',
      address: 'Pottamal Junction, Pottamal',
      city: 'Calicut',
    ),
    // Kochi
    Restaurant(
      id: 'kochi_paragon',
      name: 'Paragon Restaurant',
      address: 'MG Road, Ernakulam, Kochi',
      city: 'Kochi',
    ),
    Restaurant(
      id: 'kochi_mgrill',
      name: 'M Grill - Paragon Group',
      address: 'Lulu Mall, Edappally, Kochi',
      city: 'Kochi',
    ),
    Restaurant(
      id: 'kochi_browntown',
      name: 'Brown Town - Paragon Group',
      address: 'Panampilly Nagar, Kochi',
      city: 'Kochi',
    ),
    // Trivandrum
    Restaurant(
      id: 'tvm_paragon',
      name: 'Paragon Restaurant',
      address: 'MG Road, Thiruvananthapuram',
      city: 'Trivandrum',
    ),
    Restaurant(
      id: 'tvm_mgrill',
      name: 'M Grill - Paragon Group',
      address: 'Technopark, Thiruvananthapuram',
      city: 'Trivandrum',
    ),
    Restaurant(
      id: 'tvm_browntown',
      name: 'Brown Town - Paragon Group',
      address: 'Karamana Junction, Trivandrum',
      city: 'Trivandrum',
    ),
  ];

  /// Available time slots for table reservations (30-minute intervals).
  static const List<String> reservationTimeSlots = [
    '6:30AM', '7:00AM', '7:30AM', '8:00AM', '8:30AM',
    '9:00AM', '9:30AM', '10:00AM', '10:30AM', '11:00AM',
    '11:30AM', '12:00PM', '12:30PM', '1:00PM', '1:30PM',
    '2:00PM', '2:30PM', '3:00PM', '3:30PM', '4:00PM',
    '4:30PM', '5:00PM', '5:30PM', '6:00PM', '6:30PM',
    '7:00PM', '7:30PM', '8:00PM', '8:30PM', '9:00PM',
    '9:30PM', '10:00PM', '10:30PM',
  ];

  // ---- Take Away ------------------------------------------------------------

  /// Full-bleed neon takeaway hero photo on the Takeaway intro screen.
  static const String takeawayHero =
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1000&q=75';

  /// Top hero image for the Takeaway dashboard.
  static const String takeawayCounter =
      'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=800&q=70';

  // ---- Catering -------------------------------------------------------------

  /// Full-bleed banquet table photo on the Catering intro screen.
  static const String cateringHero =
      'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=1000&q=75';

  /// Hero image for the Catering booking header.
  static const String cateringTable =
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?auto=format&fit=crop&w=800&q=70';

  // ---- Food Planner ---------------------------------------------------------

  /// Full-bleed South Indian idli platter hero on Food Planner intro screen.
  static const String foodPlannerHero =
      'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=1000&q=75';

  /// Top hero image for Food Planner landing / date screen.
  static const String foodPlannerIdlis =
      'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=800&q=70';
}
