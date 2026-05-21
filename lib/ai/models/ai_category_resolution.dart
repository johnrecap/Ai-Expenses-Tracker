class AiCategorySuggestion {
  const AiCategorySuggestion({
    required this.name,
    required this.icon,
    required this.color,
    required this.reason,
  });

  final String name;
  final String icon;
  final int color;
  final String reason;

  AiCategorySuggestion copyWith({
    String? name,
    String? icon,
    int? color,
    String? reason,
  }) {
    return AiCategorySuggestion(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      reason: reason ?? this.reason,
    );
  }
}

enum AiCategoryResolutionSource {
  exactId,
  exactName,
  alias,
  recentHistory,
  aiSuggested,
  manual,
  none,
}

class AiCategoryResolution {
  const AiCategoryResolution({
    this.categoryId,
    required this.categoryName,
    required this.confidence,
    required this.reason,
    required this.source,
    this.suggestedCategory,
  });

  const AiCategoryResolution.none()
      : categoryId = null,
        categoryName = '',
        confidence = 0,
        reason = 'No category match found.',
        source = AiCategoryResolutionSource.none,
        suggestedCategory = null;

  final String? categoryId;
  final String categoryName;
  final double confidence;
  final String reason;
  final AiCategoryResolutionSource source;
  final AiCategorySuggestion? suggestedCategory;

  bool get hasExistingCategory =>
      categoryId != null && categoryId!.trim().isNotEmpty;

  bool get requiresUserCategoryConfirmation =>
      !hasExistingCategory && suggestedCategory != null;

  bool get isLowConfidence => confidence < 0.75;

  AiCategoryResolution copyWith({
    String? categoryId,
    bool clearCategoryId = false,
    String? categoryName,
    double? confidence,
    String? reason,
    AiCategoryResolutionSource? source,
    AiCategorySuggestion? suggestedCategory,
    bool clearSuggestedCategory = false,
  }) {
    return AiCategoryResolution(
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      source: source ?? this.source,
      suggestedCategory: clearSuggestedCategory
          ? null
          : suggestedCategory ?? this.suggestedCategory,
    );
  }
}
