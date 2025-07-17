import 'package:flutter/material.dart';
import '../../mainpage/model/quest_item.dart';

class QuestTabViewModel extends ChangeNotifier {
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  List<QuestItem> quests = [
    QuestItem(title: '출근 준비', exp: 10, gold: 5),
    QuestItem(title: 'AI 추천 집중 세션', exp: 10, gold: 5),
    QuestItem(title: '아침 스트레칭', exp: 10, gold: 5),
  ];

  void changeTab(int i) {
    if (_selectedTab != i) {
      _selectedTab = i;
      notifyListeners();
    }
  }

  void toggleQuest(int index) {
    quests[index].isCompleted = !quests[index].isCompleted;
    notifyListeners();
  }
} 