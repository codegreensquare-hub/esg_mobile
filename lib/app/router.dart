import 'package:esg_mobile/presentation/screens/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: MainScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const MainScreen();
      },
      routes: <RouteBase>[
        // GoRoute(
        //   path: 'details',
        //   builder: (BuildContext context, GoRouterState state) {
        //     return const DetailsScreen();
        //   },
        // ),
      ],
    ),
  ],
);
