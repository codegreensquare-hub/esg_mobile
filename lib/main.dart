import 'package:flutter/material.dart';
import 'package:esg_mobile/app/app.dart';

// Re-export App and MyApp for tests referencing symbols from main.dart.
export 'package:esg_mobile/app/app.dart' show App, MyApp;

void main() => runApp(const App());
