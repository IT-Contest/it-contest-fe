import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/network/dio_client.dart';
import '../../../main.dart';
import '../../../shared/alarm/widgets/daily_quest_in_progress_alarm_card.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _tzInitialized = false;

  static final Dio _dio = DioClient().dio; // ✅ 추가
  static const _storage = FlutterSecureStorage();

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          showDialog(
            context: ctx,
            builder: (context) => DailyQuestInProgressAlarmCard(
              questCount: 3,
              onPressed: () {
                Navigator.pop(context);
                navigatorKey.currentState?.pushNamed('/main');
              },
            ),
          );
        }
      },
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    _tzInitialized = true; // ✅ 추가

    debugPrint('✅ Timezone initialized (Asia/Seoul)');

    // ✅ 채널 생성
    const dailyChannel = AndroidNotificationChannel(
      'daily_channel',
      'Daily Quest Notifications',
      description: '일일 퀘스트 알림을 위한 채널입니다.',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(dailyChannel);

    const pomodoroChannel = AndroidNotificationChannel(
      'pomodoro_channel',
      'Pomodoro Notifications',
      description: '뽀모도로 사이클 완료 알림 채널입니다.',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pomodoroChannel);
    // ✅ 알림 권한 요청
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // ✅ 정확 알람 권한 확인
    if (Platform.isAndroid) {
      final hasExactAlarm = await _checkExactAlarmPermission();
      if (!hasExactAlarm) {
        await openExactAlarmSettings(); // 설정창으로 이동
      }
    }
  }

  /// 정확 알람 권한 확인용 (Android 12+)
  static Future<bool> _checkExactAlarmPermission() async {
    try {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        package: 'com.ssucheahwa.questplanner',
      );
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (_) {
      return false;
    }
  }

  static Future<void> scheduleDailyQuest(int hour, int minute) async {
    await _plugin.cancel(100); // 이전 예약 취소

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Daily Quest Notifications',
      channelDescription: '일일 퀘스트 알림을 위한 채널입니다.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin.zonedSchedule(
      100,
      '일일 퀘스트',
      '오늘의 퀘스트를 잊지 마세요!',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
    );

    debugPrint('✅ 일일 퀘스트 알림 예약 완료: ${scheduled.toLocal()}');
  }



  static Future<void> openExactAlarmSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        package: 'com.ssucheahwa.questplanner', // 앱 패키지명
      );
      await intent.launch();
    }
  }

  static Future<void> printPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('📦 예약된 알림 수: ${pending.length}');
    for (var p in pending) {
      debugPrint('➡️ ID=${p.id}, title=${p.title}, body=${p.body}');
    }
  }

  static Future<void> showPomodoroComplete() async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel', // ✅ 새 채널 ID
      'Pomodoro Notifications',
      channelDescription: '뽀모도로 사이클 완료 알림 채널입니다.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      200, // ID 중복 방지
      '🎯 뽀모도로 사이클 완료!',
      '집중 세션을 마쳤습니다. 보상이 지급되었습니다 🎁',
      details,
    );

    debugPrint('✅ Pomodoro completion push sent');
  }

  // 서버로 파티 알림 설정 동기화
  static Future<void> updatePartyNotificationSetting(bool enabled) async {
    try {
      final token = await _storage.read(key: "accessToken");
      if (token == null) {
        debugPrint("❌ 액세스 토큰이 없습니다.");
        return;
      }

      await _dio.patch(
        "/users/notifications/party",
        data: {"enabled": enabled},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      debugPrint("✅ 서버에 파티 알림 설정 동기화 완료: $enabled");
    } catch (e) {
      debugPrint("❌ 서버 동기화 실패: $e");
    }
  }
}
