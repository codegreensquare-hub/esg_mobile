import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_codegen/supabase_codegen.dart' as supa_codegen;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/app/app.dart';

// Re-export App and MyApp for tests referencing symbols from main.dart.
export 'package:esg_mobile/app/app.dart' show App, MyApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Ensure supabase_codegen generated tables reuse the initialized client
  supa_codegen.setClient(Supabase.instance.client);

  runApp(const App());
}
