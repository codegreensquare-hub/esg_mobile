import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
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

  Future<void> initialize() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

      if (isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          _firebaseMessaging.onTokenRefresh.listen(_saveToken);
          return;
        }
      }

      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveToken(token);
        }
      } catch (_) {
        // Ignore early iOS APNS-token-not-set failures.
      }

      _firebaseMessaging.onTokenRefresh.listen(_saveToken);
    }
  }

  Future<void> _saveToken(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Check if token already exists
    final existing = await Supabase.instance.client
        .from(PushNotificationTokenTable().tableName)
        .select()
        .eq(PushNotificationTokenRow.tokenField, token)
        .eq(PushNotificationTokenRow.userField, user.id)
        .maybeSingle();

    if (existing == null) {
      // Insert new token
      await Supabase.instance.client
          .from(PushNotificationTokenTable().tableName)
          .insert({
            PushNotificationTokenRow.tokenField: token,
            PushNotificationTokenRow.userField: user.id,
          });
    }
  }

  Future<void> saveTokenOnLogin() async {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    if (isIOS) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken == null) return;
    }

    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (_) {
      // Ignore early iOS APNS-token-not-set failures.
    }
  }
}
