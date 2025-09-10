import 'package:flutter/material.dart';

import 'alarm_list_page.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool dailyQuestNotification = true;
  bool questTimeNotification = true;
  bool pomodoroNotification = true;
  bool partyNotification = true;

  TimeOfDay questTime = const TimeOfDay(hour: 7, minute: 0);

  Future<void> _pickQuestTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: questTime,
    );
    if (picked != null && picked != questTime) {
      setState(() {
        questTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "알림 설정",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationListPage()),
                );
              },
              child: const ImageIcon(
                AssetImage("assets/icons/alarm_btn2.png"),
                color: Color(0xFF7958FF),
                size: 24,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionTitle("퀘스트"),
          _buildSwitchTile(
            "일일 퀘스트 알림",
            dailyQuestNotification,
                (value) => setState(() => dailyQuestNotification = value),
          ),
          // 퀘스트 알림 시간 설정 (제목 + 토글)
          SwitchListTile(
            title: const Text(
              "퀘스트 알림 시간 설정",
              style: TextStyle(fontSize: 14),
            ),
            value: questTimeNotification,
            onChanged: (value) => setState(() => questTimeNotification = value),
            activeColor: Colors.white, // 동그라미 색상
            activeTrackColor: const Color(0xFF7958FF), // 활성화 시 배경
          ),
          if (questTimeNotification)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  width: 180, // 카드 전체 너비
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      // 시간 영역
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: questTime,
                            );
                            if (picked != null) {
                              setState(() => questTime = picked);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                "${questTime.hourOfPeriod.toString().padLeft(2, '0')} : ${questTime.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // AM/PM 토글 버튼 그룹
                      Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.grey, width: 1)),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ToggleButtons(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 60,
                                  minHeight: 30,
                                ),
                                isSelected: [questTime.period == DayPeriod.am],
                                onPressed: (_) {
                                  if (questTime.period == DayPeriod.pm) {
                                    setState(() {
                                      questTime = TimeOfDay(
                                        hour: questTime.hour - 12,
                                        minute: questTime.minute,
                                      );
                                    });
                                  }
                                },
                                fillColor: const Color(0xFF7958FF),
                                selectedColor: Colors.white,
                                color: Colors.black,
                                children: const [Text("AM")],
                              ),
                            ),
                            Expanded(
                              child: ToggleButtons(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 60,
                                  minHeight: 30,
                                ),
                                isSelected: [questTime.period == DayPeriod.pm],
                                onPressed: (_) {
                                  if (questTime.period == DayPeriod.am) {
                                    setState(() {
                                      questTime = TimeOfDay(
                                        hour: questTime.hour + 12,
                                        minute: questTime.minute,
                                      );
                                    });
                                  }
                                },
                                fillColor: const Color(0xFF7958FF),
                                selectedColor: Colors.white,
                                color: Colors.black,
                                children: const [Text("PM")],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


          _buildSectionTitle("뽀모도로"),
          _buildSwitchTile(
            "뽀모도로 알림",
            pomodoroNotification,
                (value) => setState(() => pomodoroNotification = value),
          ),
          _buildSectionTitle("파티"),
          _buildSwitchTile(
            "파티 초대장 알림",
            partyNotification,
                (value) => setState(() => partyNotification = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white, // 동그라미 색상
      activeTrackColor: const Color(0xFF7958FF), // 배경 보라색
    );
  }
}

/// 🔹 AM/PM 버튼 빌더
Widget _buildAmPmButton(String text, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF7958FF) : Colors.white,
        border: Border.all(color: const Color(0xFF7958FF)),
        borderRadius: text == "AM"
            ? const BorderRadius.only(
            topLeft: Radius.circular(6), topRight: Radius.circular(6))
            : const BorderRadius.only(
            bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    ),
  );
}