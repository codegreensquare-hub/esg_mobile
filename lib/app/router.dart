import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/presentation/screens/auth/email_confirmation.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_type.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_terms.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_form.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_minor_terms.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_guardian_form.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/profile_select.screen.dart';
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
    // Minor signup screens require SignupFormData; redirect if missing (e.g. refresh/back).
    if (state.uri.path == SignupMinorTermsScreen.route ||
        state.uri.path == SignupGuardianFormScreen.route) {
      if (state.extra == null) {
        if (loggedIn) {
          debugPrint(
            '[Router.redirect] ${state.uri.path} has null extra but user is logged in → going to main',
          );
          return '/greensquare';
        }
        debugPrint(
          '[Router.redirect] ${state.uri.path} has null extra → redirecting to signup form',
        );
        return SignupFormScreen.route;
      }
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
      path: SignupTypeScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupTypeScreen();
      },
    ),
    GoRoute(
      path: SignupTermsScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupTermsScreen();
      },
    ),
    GoRoute(
      path: SignupFormScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupFormScreen();
      },
    ),
    GoRoute(
      path: SignupMinorTermsScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        debugPrint(
          '[Router.builder] ${SignupMinorTermsScreen.route} extra=${state.extra}, path=${state.uri.path}',
        );
        final formData = state.extra;
        if (formData == null || formData is! SignupFormData) {
          final destination = _authService.isLoggedIn
              ? '/greensquare'
              : SignupFormScreen.route;
          debugPrint(
            '[Router.builder] minor-terms: extra null or wrong type, redirecting to $destination',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(destination);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return SignupMinorTermsScreen(formData: formData);
      },
    ),
    GoRoute(
      path: SignupGuardianFormScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        debugPrint(
          '[Router.builder] ${SignupGuardianFormScreen.route} extra=${state.extra}, path=${state.uri.path}',
        );
        final formData = state.extra;
        if (formData == null || formData is! SignupFormData) {
          final destination = _authService.isLoggedIn
              ? '/greensquare'
              : SignupFormScreen.route;
          debugPrint(
            '[Router.builder] guardian: extra null or wrong type, redirecting to $destination',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(destination);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return SignupGuardianFormScreen(formData: formData);
      },
    ),
    GoRoute(
      path: EmailConfirmationScreen.route,
      builder: (BuildContext context, GoRouterState state) {
        return const EmailConfirmationScreen();
      },
    ),
    GoRoute(
      path: ProfileSelectScreen.route,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProfileSelectScreen(),
        );
      },
    ),
    GoRoute(
      path: '/:app',
      builder: (BuildContext context, GoRouterState state) {
        return MainScreen(initialTab: MainTab.greenSquare, state: state);
      },
    ),
  ],
);
