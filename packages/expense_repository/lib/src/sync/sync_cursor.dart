class SyncCursor {
  final String? value;
  final DateTime updatedAt;

  const SyncCursor({
    required this.value,
    required this.updatedAt,
  });

  SyncCursor.empty()
      : value = null,
        updatedAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool get hasValue => value != null && value!.isNotEmpty;
}
