import 'package:expense_repository/expense_repository.dart';

import '../models/ai_category_resolution.dart';

class AiCategoryResolver {
  const AiCategoryResolver();

  AiCategoryResolution resolve({
    required String inputText,
    String? parsedCategoryId,
    String? parsedCategoryName,
    required List<Category> activeCategories,
    List<CategoryAlias> learnedAliases = const [],
    List<Expense> recentExpenses = const [],
  }) {
    final categories = activeCategories
        .where((category) => !category.isArchived)
        .toList(growable: false);
    if (categories.isEmpty) {
      return _suggestFromText(inputText, parsedCategoryName);
    }

    final byId = _matchById(parsedCategoryId, categories);
    if (byId != null) {
      return _existing(
        byId,
        1,
        'Matched the category id returned by AI.',
        AiCategoryResolutionSource.exactId,
      );
    }

    final byName = _matchByName(parsedCategoryName, categories);
    if (byName != null) {
      return _existing(
        byName,
        0.98,
        'Matched the category name returned by AI.',
        AiCategoryResolutionSource.exactName,
      );
    }

    if (_hasParsedCategory(parsedCategoryId, parsedCategoryName)) {
      return _suggestFromText(inputText, parsedCategoryName);
    }

    final text = _normalize([inputText, parsedCategoryName].join(' '));
    final learnedAliasMatch = _matchLearnedAlias(
      text,
      categories,
      learnedAliases,
    );
    if (learnedAliasMatch != null) {
      return _existing(
        learnedAliasMatch,
        0.96,
        'Matched a confirmed user category alias.',
        AiCategoryResolutionSource.alias,
      );
    }

    final aliasMatch = _matchByAlias(text, categories);
    if (aliasMatch != null) {
      return _existing(
        aliasMatch.category,
        aliasMatch.confidence,
        'Matched source words: ${aliasMatch.aliases.take(3).join(', ')}.',
        AiCategoryResolutionSource.alias,
      );
    }

    final inferredKey = _categoryKeyFromText(text) ?? _heuristicKey(text);
    if (inferredKey != null) {
      final inferredCategory = _matchCategoryBySemanticKey(
        inferredKey,
        categories,
      );
      if (inferredCategory != null) {
        return _existing(
          inferredCategory,
          0.84,
          'Matched source words to ${inferredCategory.name}.',
          AiCategoryResolutionSource.alias,
        );
      }
    }

    final recentMatch = _matchRecentHistory(text, categories, recentExpenses);
    if (recentMatch != null) {
      return _existing(
        recentMatch,
        0.78,
        'Matched a recent confirmed expense with similar text.',
        AiCategoryResolutionSource.recentHistory,
      );
    }

    return _suggestFromText(inputText, parsedCategoryName);
  }

  Category? _matchLearnedAlias(
    String text,
    List<Category> categories,
    List<CategoryAlias> learnedAliases,
  ) {
    if (learnedAliases.isEmpty) return null;
    final activeById = {
      for (final category in categories) category.categoryId: category,
    };
    final matches = learnedAliases.where((alias) {
      return alias.phrase.trim().isNotEmpty &&
          text.contains(_normalize(alias.phrase)) &&
          activeById.containsKey(alias.categoryId);
    }).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
    if (matches.isEmpty) return null;
    return activeById[matches.first.categoryId];
  }

  Category? _matchById(String? categoryId, List<Category> categories) {
    final id = categoryId?.trim();
    if (id == null || id.isEmpty) return null;
    for (final category in categories) {
      if (category.categoryId == id) return category;
    }
    return null;
  }

  bool _hasParsedCategory(String? categoryId, String? categoryName) {
    return (categoryId?.trim().isNotEmpty ?? false) ||
        _categoryKey(categoryName).isNotEmpty;
  }

  Category? _matchByName(String? categoryName, List<Category> categories) {
    final key = _categoryKey(categoryName);
    if (key.isEmpty) return null;
    for (final category in categories) {
      if (_categoryKey(category.name) == key) return category;
    }
    return null;
  }

  _AliasMatch? _matchByAlias(String text, List<Category> categories) {
    final matches = <_AliasMatch>[];
    for (final category in categories) {
      final keys = {
        _categoryKey(category.name),
        _categoryKey(category.categoryId),
      }..removeWhere((key) => key.isEmpty);
      final aliases = keys.expand(_aliasesForKey).toSet().toList();
      final matchedAliases =
          aliases.where((alias) => text.contains(_normalize(alias))).toList();
      if (matchedAliases.isEmpty) continue;
      matchedAliases.sort((a, b) => b.length.compareTo(a.length));
      final longestAlias = matchedAliases.first.length;
      matches.add(
        _AliasMatch(
          category: category,
          aliases: matchedAliases,
          score: longestAlias + matchedAliases.length,
          confidence: matchedAliases.length > 1 ? 0.94 : 0.88,
        ),
      );
    }
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.score.compareTo(a.score));
    if (matches.length > 1 && matches[0].score == matches[1].score) {
      return null;
    }
    return matches.first;
  }

  Category? _matchRecentHistory(
    String text,
    List<Category> categories,
    List<Expense> recentExpenses,
  ) {
    if (text.isEmpty || recentExpenses.isEmpty) return null;
    final activeById = {
      for (final category in categories) category.categoryId: category,
    };
    for (final expense in recentExpenses.reversed.take(50)) {
      final category = activeById[expense.categoryId];
      if (category == null) continue;
      final haystack = _normalize(
        '${expense.description} ${expense.categoryName} ${expense.category.name}',
      );
      if (haystack.isEmpty) continue;
      final terms = haystack.split(' ').where((term) => term.length >= 3);
      if (terms.any(text.contains)) return category;
    }
    return null;
  }

  Category? _matchCategoryBySemanticKey(
    String key,
    List<Category> categories,
  ) {
    for (final category in categories) {
      if (_categoryKey(category.name) == key ||
          _categoryKey(category.categoryId) == key) {
        return category;
      }
    }
    return null;
  }

  AiCategoryResolution _suggestFromText(
    String inputText,
    String? parsedCategoryName,
  ) {
    final text = _normalize([inputText, parsedCategoryName].join(' '));
    final key = _categoryKeyFromText(text) ?? _categoryKey(parsedCategoryName);
    if (key.isEmpty) return const AiCategoryResolution.none();
    final suggestion = _suggestionForKey(key);
    return AiCategoryResolution(
      categoryName: suggestion.name,
      confidence: 0.68,
      reason:
          'No existing category matched, but the text suggests ${suggestion.name}.',
      source: AiCategoryResolutionSource.aiSuggested,
      suggestedCategory: suggestion,
    );
  }

  AiCategoryResolution _existing(
    Category category,
    double confidence,
    String reason,
    AiCategoryResolutionSource source,
  ) {
    return AiCategoryResolution(
      categoryId: category.categoryId,
      categoryName: category.name,
      confidence: confidence,
      reason: reason,
      source: source,
    );
  }

  static String _categoryKey(String? value) {
    final normalized = _normalize(value ?? '');
    if (normalized.isEmpty) return '';
    for (final entry in _categoryAliases.entries) {
      if (entry.value.any((alias) => _normalize(alias) == normalized)) {
        return entry.key;
      }
    }
    return normalized;
  }

  static String? _categoryKeyFromText(String text) {
    String? bestKey;
    var bestLength = 0;
    for (final entry in _categoryAliases.entries) {
      for (final alias in entry.value) {
        final normalizedAlias = _normalize(alias);
        if (normalizedAlias.isEmpty || !text.contains(normalizedAlias)) {
          continue;
        }
        if (normalizedAlias.length > bestLength) {
          bestKey = entry.key;
          bestLength = normalizedAlias.length;
        }
      }
    }
    return bestKey;
  }

  static String? _heuristicKey(String text) {
    if (text.contains('مواصل') ||
        text.contains('اوبر') ||
        text.contains('أوبر') ||
        text.contains('تاكسي') ||
        text.contains('كريم') ||
        text.contains('ديدي') ||
        text.contains('اندرايف') ||
        text.contains('مترو')) {
      return 'transport';
    }
    if (text.contains('بنزين') || text.contains('وقود')) return 'fuel';
    if (text.contains('اكل') ||
        text.contains('أكل') ||
        text.contains('مطعم') ||
        text.contains('قهوه') ||
        text.contains('كافيه') ||
        text.contains('دليفري')) {
      return 'food';
    }
    if (text.contains('اشتراك') || text.contains('نتفلكس')) {
      return 'subscriptions';
    }
    if (text.contains('فاتوره') ||
        text.contains('فواتير') ||
        text.contains('كهربا') ||
        text.contains('نت') ||
        text.contains('واي فاي')) {
      return 'bills';
    }
    return null;
  }

  static List<String> _aliasesForKey(String key) {
    return _categoryAliases[key] ?? [key];
  }

  static AiCategorySuggestion _suggestionForKey(String key) {
    return _suggestions[key] ??
        AiCategorySuggestion(
          name: _titleCase(key),
          icon: 'category',
          color: 0xFF607D8B,
          reason: 'Suggested from expense text.',
        );
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return 'Other';
    return value[0].toUpperCase() + value.substring(1);
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u0652\u0640]'), '')
        .replaceAll(RegExp('[إأآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r"[,.;:!?؟،؛()\[\]{}'`~@#$%^&*_+=\\/|-]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const Map<String, List<String>> _categoryAliases = {
    'food': [
      'food',
      'meal',
      'breakfast',
      'lunch',
      'dinner',
      'restaurant',
      'restaurants',
      'grocery',
      'groceries',
      'delivery',
      'cafe',
      'coffee',
      'اكل',
      'أكل',
      'طعام',
      'مطعم',
      'مطاعم',
      'دليفري',
      'بقاله',
      'بقالة',
      'سوبر ماركت',
      'قهوه',
      'قهوة',
      'كافيه',
    ],
    'transport': [
      'transport',
      'transportation',
      'uber',
      'careem',
      'indrive',
      'didi',
      'taxi',
      'metro',
      'bus',
      'microbus',
      'ride',
      'مواصلات',
      'المواصلات',
      'اوبر',
      'أوبر',
      'كريم',
      'اندرايف',
      'ديدي',
      'تاكسي',
      'مترو',
      'اتوبيس',
      'أتوبيس',
      'ميكروباص',
    ],
    'shopping': [
      'shopping',
      'shop',
      'clothes',
      'store',
      'market',
      'تسوق',
      'مشتريات',
      'شراء',
      'لبس',
      'ملابس',
      'محل',
      'سوق',
    ],
    'bills': [
      'bills',
      'bill',
      'electricity',
      'water',
      'internet',
      'internet bill',
      'wifi',
      'phone bill',
      'mobile bill',
      'utilities',
      'فواتير',
      'فاتوره',
      'فاتورة',
      'كهرباء',
      'كهربا',
      'مياه',
      'انترنت',
      'نت',
      'واي فاي',
      'تليفون',
      'موبايل',
      'رسوم بنك',
    ],
    'entertainment': [
      'entertainment',
      'cinema',
      'movie',
      'games',
      'game',
      'outing',
      'ترفيه',
      'سينما',
      'العاب',
      'ألعاب',
      'خروجه',
      'خروجة',
    ],
    'health': [
      'health',
      'doctor',
      'pharmacy',
      'medicine',
      'clinic',
      'صحه',
      'صحة',
      'دكتور',
      'صيدليه',
      'صيدلية',
      'علاج',
    ],
    'travel': [
      'travel',
      'flight',
      'hotel',
      'trip',
      'سفر',
      'طيران',
      'فندق',
      'رحله',
      'رحلة',
    ],
    'subscriptions': [
      'subscription',
      'subscriptions',
      'netflix',
      'spotify',
      'youtube',
      'prime',
      'shahid',
      'اشتراك',
      'اشتراكات',
      'نتفلكس',
      'سبوتيفاي',
      'يوتيوب',
      'شاهد',
    ],
    'education': [
      'education',
      'course',
      'school',
      'book',
      'تعليم',
      'كورس',
      'مدرسه',
      'مدرسة',
      'كتاب',
    ],
    'rent': [
      'rent',
      'lease',
      'ايجار',
      'إيجار',
      'الايجار',
      'الإيجار',
    ],
    'fuel': [
      'fuel',
      'gas',
      'بنزين',
      'وقود',
    ],
  };

  static const Map<String, AiCategorySuggestion> _suggestions = {
    'food': AiCategorySuggestion(
      name: 'Food',
      icon: 'restaurant',
      color: 0xFFFF7043,
      reason: 'Food or restaurant words were detected.',
    ),
    'transport': AiCategorySuggestion(
      name: 'Transport',
      icon: 'directions_car',
      color: 0xFF42A5F5,
      reason: 'Transport words such as Uber, taxi, or metro were detected.',
    ),
    'shopping': AiCategorySuggestion(
      name: 'Shopping',
      icon: 'shopping_bag',
      color: 0xFFAB47BC,
      reason: 'Shopping words were detected.',
    ),
    'bills': AiCategorySuggestion(
      name: 'Bills',
      icon: 'receipt_long',
      color: 0xFFFFCA28,
      reason: 'Utility or bill words were detected.',
    ),
    'entertainment': AiCategorySuggestion(
      name: 'Entertainment',
      icon: 'theaters',
      color: 0xFFEC407A,
      reason: 'Entertainment words were detected.',
    ),
    'health': AiCategorySuggestion(
      name: 'Health',
      icon: 'local_hospital',
      color: 0xFF66BB6A,
      reason: 'Health or pharmacy words were detected.',
    ),
    'travel': AiCategorySuggestion(
      name: 'Travel',
      icon: 'flight',
      color: 0xFF26A69A,
      reason: 'Travel words were detected.',
    ),
    'subscriptions': AiCategorySuggestion(
      name: 'Subscriptions',
      icon: 'subscriptions',
      color: 0xFF5C6BC0,
      reason: 'Subscription or streaming service words were detected.',
    ),
    'education': AiCategorySuggestion(
      name: 'Education',
      icon: 'school',
      color: 0xFF8D6E63,
      reason: 'Education words were detected.',
    ),
    'rent': AiCategorySuggestion(
      name: 'Rent',
      icon: 'home_work',
      color: 0xFF78909C,
      reason: 'Rent words were detected.',
    ),
    'fuel': AiCategorySuggestion(
      name: 'Fuel',
      icon: 'local_gas_station',
      color: 0xFF26A69A,
      reason: 'Fuel words were detected.',
    ),
  };
}

class _AliasMatch {
  const _AliasMatch({
    required this.category,
    required this.aliases,
    required this.score,
    required this.confidence,
  });

  final Category category;
  final List<String> aliases;
  final int score;
  final double confidence;
}
