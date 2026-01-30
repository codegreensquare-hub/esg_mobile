import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/presentation/screens/auth/email_confirmation.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/login.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup.screen.dart';
import 'package:esg_mobile/presentation/screens/main.screen.dart';
import 'package:esg_mobile/app/app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.
final UserAuthService _authService = UserAuthService.instance;

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  refreshListenable: _authService,
  redirect: (context, state) {
    final loggedIn = _authService.isLoggedIn;
    final needsConfirmation = _authService.requiresEmailVerification;
    final isOnConfirmation = state.uri.path == EmailConfirmationScreen.route;

    if (state.uri.path == '/') {
      return '/greensquare';
    }

    if (!loggedIn && isOnConfirmation) {
      return MainScreen.route;
    }
    if (needsConfirmation && !isOnConfirmation) {
      return EmailConfirmationScreen.route;
    }
    if (!needsConfirmation && isOnConfirmation) {
      return MainScreen.route;
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/codegreen',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.codeGreen, state: state);
      },
    ),
    GoRoute(
      path: '/codegreen/original',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.codeGreen, state: state);
      },
    ),
    GoRoute(
      path: '/codegreen/curation',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.codeGreen, state: state);
      },
    ),
    GoRoute(
      path: '/codegreen/about',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.codeGreen, state: state);
      },
    ),
    GoRoute(
      path: '/codegreen/lookbook',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.codeGreen, state: state);
      },
    ),
    GoRoute(
      path: '/codegreen/event',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.codeGreen, state: state);
      },
    ),
    GoRoute(
      path: '/greensquare/store',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.greenSquare, state: state);
      },
    ),
    GoRoute(
      path: '/greensquare/missions',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.greenSquare, state: state);
      },
    ),
    GoRoute(
      path: '/greensquare/account',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.greenSquare, state: state);
      },
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.greenSquare, state: state);
      },
    ),
    GoRoute(
      path: '/:app',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.greenSquare, state: state);
      },
    ),
    GoRoute(
      path: LoginScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: SignUpScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: EmailConfirmationScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const EmailConfirmationScreen();
      },
    ),
  ],
);
