import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/notification_service.dart';
import 'alarm_list_page.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;

  bool dailyQuestNotification = true;
  bool questTimeNotification = true;
  bool pomodoroNotification = true;
  bool partyNotification = true;

  TimeOfDay questTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyQuestNotification = prefs.getBool('dailyQuestNotification') ?? true;
      questTimeNotification = prefs.getBool('questTimeNotification') ?? true;
      pomodoroNotification = prefs.getBool('pomodoroNotification') ?? true;
      partyNotification = prefs.getBool('partyNotification') ?? true;

      final hour = prefs.getInt('questTimeHour');
      final minute = prefs.getInt('questTimeMinute');
      if (hour != null && minute != null) {
        questTime = TimeOfDay(hour: hour, minute: minute);
      }

      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // 파티 알림 설정일 때 서버로 동기화
    if (key == 'partyNotification') {
      await NotificationService.updatePartyNotificationSetting(value);
    }

    // 일일 퀘스트 알림 OFF 시 예약 취소
    if (key == 'dailyQuestNotification' && value == false) {
      await NotificationService.plugin.cancel(100);
      debugPrint('🛑 일일 퀘스트 알림 비활성화됨');
    }

    // 퀘스트 알림 시간 설정 OFF 시 예약 취소
    if (key == 'questTimeNotification' && value == false) {
      await NotificationService.plugin.cancel(100);
      debugPrint('🛑 퀘스트 알림 시간 설정 비활성화됨');
    }
  }

  Future<void> _saveQuestTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('questTimeHour', time.hour);
    await prefs.setInt('questTimeMinute', time.minute);

    await NotificationService.scheduleDailyQuest(time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                AssetImage("assets/icons/alarm_btn1.png"),
                color: Color(0xFF7958FF),
                size: 28,
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

          // ✅ 일일 퀘스트 알림 토글
          _buildSwitchTile(
            "일일 퀘스트 알림",
            dailyQuestNotification,
                (value) {
              setState(() => dailyQuestNotification = value);
              _saveBool('dailyQuestNotification', value);
            },
          ),

          // ✅ dailyQuestNotification이 켜져 있어야만 시간 설정 옵션 보임
          if (dailyQuestNotification) ...[
            _buildSwitchTile(
              "퀘스트 알림 시간 설정",
              questTimeNotification,
                  (value) {
                setState(() => questTimeNotification = value);
                _saveBool('questTimeNotification', value);
              },
            ),

            if (questTimeNotification)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    width: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: questTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogBackgroundColor: Colors.white,
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF7958FF),
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Color(0xFF7958FF),
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() => questTime = picked);
                                _saveQuestTime(picked);
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
                                      _saveQuestTime(questTime);
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
                                      _saveQuestTime(questTime);
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
          ],

          _buildSectionTitle("뽀모도로"),
          _buildSwitchTile(
            "뽀모도로 알림",
            pomodoroNotification,
                (value) {
              setState(() => pomodoroNotification = value);
              _saveBool('pomodoroNotification', value);
            },
          ),

          _buildSectionTitle("파티"),
          _buildSwitchTile(
            "파티 초대장 알림",
            partyNotification,
                (value) {
              setState(() => partyNotification = value);
              _saveBool('partyNotification', value);
            },
          ),

          // // ✅ 여기 테스트 버튼 추가!
          // _buildSectionTitle("테스트"),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       NotificationService.showNow();
          //     },
          //     child: const Text("즉시 알림"),
          //   ),
          // ),

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
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF7958FF),
      inactiveThumbColor: const Color(0xFF7958FF),
      inactiveTrackColor: Colors.white,
      trackOutlineColor: WidgetStateProperty.all(const Color(0xFF7958FF)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
