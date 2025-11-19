class QuestItem {
  final String title;
  final int exp;
  final int gold;
  bool isCompleted;

  QuestItem({
    required this.title,
    required this.exp,
    required this.gold,
    this.isCompleted = false,
  });
}