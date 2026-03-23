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

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Firebase is independent of Supabase — run it fully in the background.
  final firebaseFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Resolve Supabase credentials as fast as possible.
  // On web the .env is always blank, so start the Netlify config fetch
  // immediately in parallel with dotenv (which is a no-op on web).
  final Future<http.Response?> configFuture;
  if (kIsWeb) {
    configFuture = http
        .get(Uri.parse('/.netlify/functions/config'))
        .catchError((_) => http.Response('', 500));
  } else {
    configFuture = Future.value(null);
  }

  final (_, configResponse) = await (
    dotenv.load(fileName: '.env', isOptional: true),
    configFuture,
  ).wait;

  var supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '');
  var supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  if ((supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) &&
      configResponse != null) {
    try {
      if (configResponse.statusCode == 200 &&
          configResponse.body.isNotEmpty) {
        final decoded = jsonDecode(configResponse.body);
        if (decoded is Map<String, dynamic>) {
          supabaseUrl = (decoded['SUPABASE_URL'] ?? supabaseUrl).toString();
          supabaseAnonKey =
              (decoded['SUPABASE_ANON_KEY'] ?? supabaseAnonKey).toString();
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
      'or configure Netlify env vars for the config function (web).',
    );
  }

  // Initialize Supabase immediately — don't wait for Firebase.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  supa_codegen.setClient(Supabase.instance.client);
  UserAuthService.instance;

  // Launch the app — Firebase and push notifications finish in the background.
  runApp(const App());

  // Wait for Firebase before registering messaging handlers.
  await firebaseFuture;
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  PushNotificationService.instance.initialize();
}
