import 'dart:convert';

import 'package:esg_mobile/app/app.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/push_notification.service.dart';
import 'package:esg_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_codegen/supabase_codegen.dart' as supa_codegen;
import 'package:supabase_flutter/supabase_flutter.dart';

// Re-export App and MyApp for tests referencing symbols from main.dart.
export 'package:esg_mobile/app/app.dart' show App, MyApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env', isOptional: true);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  var supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '');
  var supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  if ((supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) &&
      kIsWeb) {
    try {
      final response = await http.get(Uri.parse('/.netlify/functions/config'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          supabaseUrl = (decoded['SUPABASE_URL'] ?? supabaseUrl).toString();
          supabaseAnonKey = (decoded['SUPABASE_ANON_KEY'] ?? supabaseAnonKey)
              .toString();
        }
      }
    } catch (_) {
      // Ignore and validate below.
    }
  }

  if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
      'Provide them via the root .env file (local), '
      'or configure Netlify env vars for the config function (web).d',
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Ensure supabase_codegen generated tables reuse the initialized client
  supa_codegen.setClient(Supabase.instance.client);

  // Ensure auth state listener is live (also syncs push token if logged in)
  UserAuthService.instance;

  // Initialize push notifications
  await PushNotificationService.instance.initialize();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  runApp(const App());
}
