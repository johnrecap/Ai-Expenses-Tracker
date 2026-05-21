import 'package:flutter/material.dart';

class CategoryIconDefinition {
  const CategoryIconDefinition({
    required this.key,
    required this.label,
    required this.group,
    required this.icon,
    this.legacyAliases = const [],
  });

  final String key;
  final String label;
  final String group;
  final IconData icon;
  final List<String> legacyAliases;
}

class CategoryIconRegistry {
  const CategoryIconRegistry._();

  static const fallback = CategoryIconDefinition(
    key: 'other.category',
    label: 'Category',
    group: 'Other',
    icon: Icons.category_outlined,
    legacyAliases: ['category', 'other', ''],
  );

  static const definitions = <CategoryIconDefinition>[
    CategoryIconDefinition(
      key: 'food.dining',
      label: 'Dining',
      group: 'Food',
      icon: Icons.restaurant_outlined,
      legacyAliases: ['food', 'restaurant', 'dining'],
    ),
    CategoryIconDefinition(
      key: 'food.groceries',
      label: 'Groceries',
      group: 'Food',
      icon: Icons.local_grocery_store_outlined,
      legacyAliases: ['groceries', 'grocery'],
    ),
    CategoryIconDefinition(
      key: 'food.coffee',
      label: 'Coffee',
      group: 'Food',
      icon: Icons.local_cafe_outlined,
    ),
    CategoryIconDefinition(
      key: 'food.fast_food',
      label: 'Fast food',
      group: 'Food',
      icon: Icons.fastfood_outlined,
    ),
    CategoryIconDefinition(
      key: 'transport.car',
      label: 'Car',
      group: 'Transport',
      icon: Icons.directions_car_outlined,
      legacyAliases: ['transport', 'transportation'],
    ),
    CategoryIconDefinition(
      key: 'transport.taxi',
      label: 'Taxi',
      group: 'Transport',
      icon: Icons.local_taxi_outlined,
    ),
    CategoryIconDefinition(
      key: 'transport.bus',
      label: 'Bus',
      group: 'Transport',
      icon: Icons.directions_bus_outlined,
    ),
    CategoryIconDefinition(
      key: 'transport.train',
      label: 'Train',
      group: 'Transport',
      icon: Icons.train_outlined,
    ),
    CategoryIconDefinition(
      key: 'transport.fuel',
      label: 'Fuel',
      group: 'Transport',
      icon: Icons.local_gas_station_outlined,
      legacyAliases: ['fuel', 'gas'],
    ),
    CategoryIconDefinition(
      key: 'bills.receipt',
      label: 'Bills',
      group: 'Bills',
      icon: Icons.receipt_long_outlined,
      legacyAliases: ['bills', 'bill'],
    ),
    CategoryIconDefinition(
      key: 'bills.electricity',
      label: 'Electricity',
      group: 'Bills',
      icon: Icons.bolt_outlined,
    ),
    CategoryIconDefinition(
      key: 'bills.water',
      label: 'Water',
      group: 'Bills',
      icon: Icons.water_drop_outlined,
    ),
    CategoryIconDefinition(
      key: 'bills.internet',
      label: 'Internet',
      group: 'Bills',
      icon: Icons.wifi_outlined,
      legacyAliases: ['tech', 'internet'],
    ),
    CategoryIconDefinition(
      key: 'bills.phone',
      label: 'Phone',
      group: 'Bills',
      icon: Icons.phone_iphone_outlined,
    ),
    CategoryIconDefinition(
      key: 'shopping.bag',
      label: 'Shopping',
      group: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      legacyAliases: ['shopping', 'shop'],
    ),
    CategoryIconDefinition(
      key: 'shopping.cart',
      label: 'Cart',
      group: 'Shopping',
      icon: Icons.shopping_cart_outlined,
    ),
    CategoryIconDefinition(
      key: 'shopping.clothes',
      label: 'Clothes',
      group: 'Shopping',
      icon: Icons.checkroom_outlined,
    ),
    CategoryIconDefinition(
      key: 'shopping.gifts',
      label: 'Gifts',
      group: 'Shopping',
      icon: Icons.card_giftcard_outlined,
    ),
    CategoryIconDefinition(
      key: 'home.house',
      label: 'Home',
      group: 'Home',
      icon: Icons.home_outlined,
      legacyAliases: ['home'],
    ),
    CategoryIconDefinition(
      key: 'home.rent',
      label: 'Rent',
      group: 'Home',
      icon: Icons.home_work_outlined,
      legacyAliases: ['rent'],
    ),
    CategoryIconDefinition(
      key: 'home.furniture',
      label: 'Furniture',
      group: 'Home',
      icon: Icons.chair_outlined,
    ),
    CategoryIconDefinition(
      key: 'home.cleaning',
      label: 'Cleaning',
      group: 'Home',
      icon: Icons.cleaning_services_outlined,
    ),
    CategoryIconDefinition(
      key: 'lifestyle.entertainment',
      label: 'Entertainment',
      group: 'Lifestyle',
      icon: Icons.movie_outlined,
      legacyAliases: ['entertainment'],
    ),
    CategoryIconDefinition(
      key: 'lifestyle.games',
      label: 'Games',
      group: 'Lifestyle',
      icon: Icons.sports_esports_outlined,
    ),
    CategoryIconDefinition(
      key: 'lifestyle.sports',
      label: 'Sports',
      group: 'Lifestyle',
      icon: Icons.fitness_center_outlined,
    ),
    CategoryIconDefinition(
      key: 'lifestyle.pet',
      label: 'Pet',
      group: 'Lifestyle',
      icon: Icons.pets_outlined,
      legacyAliases: ['pet'],
    ),
    CategoryIconDefinition(
      key: 'health.medical',
      label: 'Medical',
      group: 'Health',
      icon: Icons.local_hospital_outlined,
      legacyAliases: ['health'],
    ),
    CategoryIconDefinition(
      key: 'health.pharmacy',
      label: 'Pharmacy',
      group: 'Health',
      icon: Icons.medication_outlined,
    ),
    CategoryIconDefinition(
      key: 'health.wellness',
      label: 'Wellness',
      group: 'Health',
      icon: Icons.spa_outlined,
    ),
    CategoryIconDefinition(
      key: 'work.briefcase',
      label: 'Work',
      group: 'Work',
      icon: Icons.work_outline,
    ),
    CategoryIconDefinition(
      key: 'work.office',
      label: 'Office',
      group: 'Work',
      icon: Icons.business_center_outlined,
    ),
    CategoryIconDefinition(
      key: 'work.tools',
      label: 'Tools',
      group: 'Work',
      icon: Icons.handyman_outlined,
    ),
    CategoryIconDefinition(
      key: 'education.school',
      label: 'School',
      group: 'Education',
      icon: Icons.school_outlined,
      legacyAliases: ['education'],
    ),
    CategoryIconDefinition(
      key: 'education.books',
      label: 'Books',
      group: 'Education',
      icon: Icons.menu_book_outlined,
    ),
    CategoryIconDefinition(
      key: 'education.course',
      label: 'Course',
      group: 'Education',
      icon: Icons.cast_for_education_outlined,
    ),
    CategoryIconDefinition(
      key: 'subscriptions.play',
      label: 'Streaming',
      group: 'Subscriptions',
      icon: Icons.play_circle_outline,
      legacyAliases: ['subscriptions', 'subscription'],
    ),
    CategoryIconDefinition(
      key: 'subscriptions.repeat',
      label: 'Recurring',
      group: 'Subscriptions',
      icon: Icons.subscriptions_outlined,
    ),
    CategoryIconDefinition(
      key: 'subscriptions.cloud',
      label: 'Cloud',
      group: 'Subscriptions',
      icon: Icons.cloud_outlined,
    ),
    CategoryIconDefinition(
      key: 'travel.flight',
      label: 'Flight',
      group: 'Travel',
      icon: Icons.flight_outlined,
      legacyAliases: ['travel'],
    ),
    CategoryIconDefinition(
      key: 'travel.hotel',
      label: 'Hotel',
      group: 'Travel',
      icon: Icons.hotel_outlined,
    ),
    CategoryIconDefinition(
      key: 'travel.map',
      label: 'Trip',
      group: 'Travel',
      icon: Icons.map_outlined,
    ),
    CategoryIconDefinition(
      key: 'finance.wallet',
      label: 'Wallet',
      group: 'Other',
      icon: Icons.account_balance_wallet_outlined,
      legacyAliases: ['wallet'],
    ),
    CategoryIconDefinition(
      key: 'finance.card',
      label: 'Card',
      group: 'Other',
      icon: Icons.credit_card_outlined,
      legacyAliases: ['card'],
    ),
    CategoryIconDefinition(
      key: 'finance.savings',
      label: 'Savings',
      group: 'Other',
      icon: Icons.savings_outlined,
      legacyAliases: ['savings'],
    ),
    CategoryIconDefinition(
      key: 'finance.cash',
      label: 'Cash',
      group: 'Other',
      icon: Icons.payments_outlined,
      legacyAliases: ['cash', 'money'],
    ),
    fallback,
  ];

  static List<String> get groups {
    final values = <String>[];
    for (final definition in definitions) {
      if (!values.contains(definition.group)) values.add(definition.group);
    }
    return values;
  }

  static List<CategoryIconDefinition> definitionsForGroup(String group) {
    return definitions
        .where((definition) => definition.group == group)
        .toList(growable: false);
  }

  static CategoryIconDefinition resolve(String? key) {
    final normalized = key?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return fallback;
    for (final definition in definitions) {
      if (definition.key == normalized ||
          definition.legacyAliases
              .map((alias) => alias.toLowerCase())
              .contains(normalized)) {
        return definition;
      }
    }
    return fallback;
  }
}
