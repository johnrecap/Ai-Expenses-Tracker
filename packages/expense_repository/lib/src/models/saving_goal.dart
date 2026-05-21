import 'package:expense_repository/expense_repository.dart';

class SavingGoal {
  final String goalId;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingGoal({
    required this.goalId,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.deadline,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = SavingGoal(
    goalId: '',
    userId: '',
    name: '',
    targetAmount: 0,
    currentAmount: 0,
    currency: 'EGP',
    isArchived: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  double get progressPercent {
    if (targetAmount <= 0) return 0;
    final percent = (currentAmount / targetAmount) * 100;
    return percent < 0 ? 0 : percent;
  }

  double get progressRatio => (progressPercent / 100).clamp(0, 1).toDouble();

  double get remainingAmount => targetAmount - currentAmount;

  bool get isComplete => targetAmount > 0 && currentAmount >= targetAmount;

  SavingGoal copyWith({
    String? goalId,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? deadline,
    bool clearDeadline = false,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingGoal(
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      deadline: clearDeadline ? null : deadline ?? this.deadline,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  SavingGoalEntity toEntity() {
    return SavingGoalEntity(
      goalId: goalId,
      userId: userId,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      currency: currency,
      deadline: deadline,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SavingGoal fromEntity(SavingGoalEntity entity) {
    return SavingGoal(
      goalId: entity.goalId,
      userId: entity.userId,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      currency: entity.currency,
      deadline: entity.deadline,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
