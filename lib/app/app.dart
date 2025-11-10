import 'package:flutter/material.dart';

import 'package:esg_mobile/app/router.dart';
import 'package:esg_mobile/core/theme/util.dart';
import 'package:esg_mobile/core/theme/theme.dart';

/// Root application widget wiring theme + router.
class App extends StatelessWidget {
  const App({super.key});

  MaterialTheme _materialTheme(BuildContext context) {
    // Choose downloadable fonts; adjust families as needed.
    final textTheme = createTextTheme(context, 'Noto Sans KR', 'EB Garamond');
    return MaterialTheme(textTheme);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final materialTheme = _materialTheme(context);
    // Configure GoRouter (provided by router.dart import) and themes.
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ESG Mobile',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      routerConfig: router,
    );
  }
}

// Backwards-compatible alias for existing tests/widgets expecting `MyApp`.
class MyApp extends App {
  const MyApp({super.key});
}
