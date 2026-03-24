import 'dart:io' show Platform;

import 'package:esg_mobile/data/models/supabase/tables/push_notification_token.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Top-level background handler – must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '🔔 PushNotificationService: 📩 BACKGROUND message — '
    'id=${message.messageId}, '
    'title=${message.notification?.title}, '
    'body=${message.notification?.body}, '
    'data=${message.data}',
  );
}

/// Android notification channel for high-importance notifications.
const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'esg_high_importance_channel',
  'ESG Notifications',
  description: 'Push notifications for ESG Mobile',
  importance: Importance.high,
);

class PushNotificationService {
  static PushNotificationService? _instance;
  static PushNotificationService get instance {
    _instance ??= PushNotificationService._();
    return _instance!;
  }

  PushNotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _lastKnownToken;

  Future<void> initialize() async {
    debugPrint('🔔 PushNotificationService: initialize() START');

    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '🔔 PushNotificationService: permission status = ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('🔔 PushNotificationService: ❌ permission DENIED — aborting');
      return;
    }

    // Set up local notifications for foreground display
    await _initLocalNotifications();
    debugPrint('🔔 PushNotificationService: local notifications initialized');

    // Set foreground notification presentation options (iOS)
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
      '🔔 PushNotificationService: foreground presentation options set',
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        '🔔 PushNotificationService: ✉️ onMessage RECEIVED — '
        'id=${message.messageId}, '
        'title=${message.notification?.title}, '
        'body=${message.notification?.body}, '
        'data=${message.data}',
      );
      _handleForegroundMessage(message);
    });

    // Listen for notification taps (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
        '🔔 PushNotificationService: 👆 onMessageOpenedApp — '
        'id=${message.messageId}, data=${message.data}',
      );
      _handleNotificationTap(message);
    });

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    debugPrint(
      '🔔 PushNotificationService: initialMessage = ${initialMessage?.messageId ?? "null"}',
    );
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Token handling
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      debugPrint(
        '🔔 PushNotificationService: 🔄 token refreshed: ${token.substring(0, 20)}...',
      );
      _lastKnownToken = token;
      await _saveTokenIfPossible(token);
    });

    await _fetchAndPersistTokenIfPossible();
    debugPrint('🔔 PushNotificationService: initialize() DONE');
  }

  /// Initialize flutter_local_notifications for showing notifications
  /// when the app is in the foreground.
  Future<void> _initLocalNotifications() async {
    if (kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          debugPrint(
            'PushNotificationService: local notification tapped: ${details.payload}',
          );
        }
        // Handle local notification tap if needed
      },
    );

    // Create the Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// Display a foreground notification using flutter_local_notifications.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint(
        'PushNotificationService: foreground message: ${message.messageId}',
      );
    }

    final notification = message.notification;
    if (notification == null) return;

    // Try to get the image URL from the notification
    final imageUrl =
        notification.android?.imageUrl ??
        message.data['image'] ??
        message.data['imageUrl'];

    BigPictureStyleInformation? bigPictureStyle;
    ByteArrayAndroidBitmap? largeIcon;

    if (imageUrl != null && !kIsWeb && Platform.isAndroid) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final bitmap = ByteArrayAndroidBitmap(response.bodyBytes);
          bigPictureStyle = BigPictureStyleInformation(
            bitmap,
            hideExpandedLargeIcon: true,
            contentTitle: notification.title,
            summaryText: notification.body,
          );
          largeIcon = bitmap;
        }
      } catch (e) {
        debugPrint('PushNotificationService: failed to download image: $e');
      }
    }

    // Show the notification via local notifications plugin
    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: largeIcon,
          styleInformation: bigPictureStyle,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['landing_page_url'],
    );
  }

  /// Handle notification tap when app is in background/terminated.
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        'PushNotificationService: notification tapped: ${message.data}',
      );
    }

    // Navigate based on the landing_page_url or other data if needed.
    // This can be extended to use a global navigator key or go_router.
    final landingUrl = message.data['landing_page_url'];
    if (landingUrl != null && kDebugMode) {
      debugPrint('PushNotificationService: landing URL: $landingUrl');
    }
  }

  // ── Token management (unchanged) ──────────────────────────────────────

  Future<void> _fetchAndPersistTokenIfPossible() async {
    debugPrint('🔔 PushNotificationService: fetching FCM token...');
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint('🔔 PushNotificationService: ❌ FCM token is NULL');
        return;
      }
      debugPrint(
        '🔔 PushNotificationService: ✅ FCM token = ${token.substring(0, 20)}...',
      );
      _lastKnownToken = token;
      await _saveTokenIfPossible(token);
    } catch (e, stackTrace) {
      debugPrint('🔔 PushNotificationService: ❌ getToken FAILED: $e');
      debugPrint('🔔 PushNotificationService: stackTrace: $stackTrace');
    }
  }

  Future<void> _saveTokenIfPossible(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('PushNotificationService: skipping save — no user logged in.');
      return;
    }

    debugPrint(
      'PushNotificationService: saving token=${token.substring(0, 10)}... '
      'userId=$userId',
    );

    try {
      await Supabase.instance.client
          .from(PushNotificationTokenTable().tableName)
          .upsert(
            {
              PushNotificationTokenRow.tokenField: token,
              PushNotificationTokenRow.userField: userId,
            },
            onConflict:
                '${PushNotificationTokenRow.userField},${PushNotificationTokenRow.tokenField}',
          );

      debugPrint('PushNotificationService: token saved successfully.');
    } catch (e, stackTrace) {
      debugPrint('PushNotificationService: upsert FAILED: $e');
      debugPrint('PushNotificationService: stackTrace: $stackTrace');
    }
  }

  Future<void> saveTokenOnLogin() async {
    await syncTokenForCurrentUser();
  }

  Future<void> syncTokenForCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final token = _lastKnownToken;
    if (token != null) {
      await _saveTokenIfPossible(token);
      return;
    }

    await _fetchAndPersistTokenIfPossible();
  }
}
