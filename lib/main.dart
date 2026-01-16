import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_codegen/supabase_codegen.dart' as supa_codegen;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esg_mobile/app/app.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/push_notification.service.dart';
import 'package:esg_mobile/firebase_options.dart';

// Re-export App and MyApp for tests referencing symbols from main.dart.
export 'package:esg_mobile/app/app.dart' show App, MyApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/env/config.env', isOptional: true);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '');
  final supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
      'Provide them via assets/env/config.env.',
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

  runApp(const App());
}
