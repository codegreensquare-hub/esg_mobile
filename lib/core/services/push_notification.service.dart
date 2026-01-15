import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/data/models/supabase/tables/push_notification_token.dart';

class PushNotificationService {
  static PushNotificationService? _instance;
  static PushNotificationService get instance {
    _instance ??= PushNotificationService._();
    return _instance!;
  }

  PushNotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _lastKnownToken;

  Future<void> initialize() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        _lastKnownToken = token;
        await _saveTokenIfPossible(token);
      });

      await _fetchAndPersistTokenIfPossible();
    }
  }

  Future<void> _fetchAndPersistTokenIfPossible() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('PushNotificationService: FCM token is null.');
        }
        return;
      }
      _lastKnownToken = token;
      await _saveTokenIfPossible(token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PushNotificationService: getToken failed: $e');
      }
    }
  }

  Future<void> _saveTokenIfPossible(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      await Supabase.instance.client
          .from(PushNotificationTokenTable().tableName)
          .upsert({
            PushNotificationTokenRow.tokenField: token,
            if (userId != null) PushNotificationTokenRow.userField: userId,
          }, onConflict: PushNotificationTokenRow.tokenField);

      if (kDebugMode) {
        debugPrint(
          'PushNotificationService: upserted token (userId=${userId ?? 'null'}).',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PushNotificationService: upsert failed: $e');
      }
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
