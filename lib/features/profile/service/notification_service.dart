import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart';
import '../../../shared/alarm/widgets/daily_quest_in_progress_alarm_card.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

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

    // ✅ 채널 생성 (여기가 핵심!)
    const dailyChannel = AndroidNotificationChannel(
      'daily_channel', // 채널 ID
      'Daily Quest Notifications', // 채널 이름
      description: '일일 퀘스트 알림을 위한 채널입니다.',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(dailyChannel);

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleDailyQuest(int hour, int minute) async {
    // 기존 예약 취소
    await _plugin.cancel(100);

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Daily Quest Notifications',
      channelDescription: '일일 퀘스트 알림을 위한 채널입니다.',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      100,
      '일일 퀘스트',
      '오늘 해야할 퀘스트가 있어요!',
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
    );

    debugPrint('📅 DailyQuest 알림 예약됨: ${scheduled.toLocal()}');
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

  static Future<void> scheduleExact(DateTime dateTime) async {
    await _plugin.zonedSchedule(
      1,
      '테스트 알림',
      '10초 뒤에 도착하는 테스트 알림입니다!',
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // static Future<void> showNow() async {
  //   await _plugin.show(
  //     1000,
  //     '즉시 알림',
  //     '이건 바로 뜨는 알림입니다!',
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'instant_channel',
  //         'Instant Test',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //   );
  // }

}
