class TrackingStreak {
  final int currentStreakDays;
  final bool hasTrackedToday;
  final DateTime referenceDate;
  final DateTime? lastTrackedDate;

  const TrackingStreak({
    required this.currentStreakDays,
    required this.hasTrackedToday,
    required this.referenceDate,
    this.lastTrackedDate,
  });

  bool get isEmpty => currentStreakDays == 0;
}
