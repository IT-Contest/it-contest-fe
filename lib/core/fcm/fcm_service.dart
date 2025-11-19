import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// 초기화
  static Future<void> initFCM() async {
    // 알림 권한 요청
    await _fcm.requestPermission();

    // FCM 토큰 확인 (서버에 전달 필요)
    final token = await _fcm.getToken();
    debugPrint("📌 FCM Token: $token");

    // Foreground 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground Message: ${message.data}");

      // 알림 내용이 있으면 로컬 알림으로 띄우기
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Background/Terminated 상태에서 클릭 시 → 앱만 켜짐 (추가 라우팅 X)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🔔 알림 클릭: 앱이 열렸습니다.");
      // 아무 동작도 안 해서 기본 홈으로만 진입
    });

    // Local 알림 초기화
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("🔔 로컬 알림 클릭: 앱이 열렸습니다.");
        // 아무 동작 안 함 → 앱만 켜짐
      },
    );
  }

  /// 로컬 알림 표시
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'party_channel',
      'Party Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? "알림",
      message.notification?.body ?? "새 알림이 도착했습니다.",
      notificationDetails,
    );
  }
}