import 'dart:async';

import 'package:esg_mobile/data/models/supabase/enums/user_type.dart';
import 'package:esg_mobile/data/models/supabase/tables/user.dart';
import 'package:esg_mobile/core/services/push_notification.service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service that exposes the current Supabase user plus helper auth
/// operations. Widgets can listen to [UserAuthService.instance] for changes.
class UserAuthService extends ChangeNotifier {
  UserAuthService._internal() : _client = Supabase.instance.client {
    _currentUser = _client.auth.currentUser;
    unawaited(PushNotificationService.instance.syncTokenForCurrentUser());
    unawaited(_syncUserRowFor(_currentUser));
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      final wasLoggedOut = _currentUser == null;
      _updateUser(data.session?.user);
      if (wasLoggedOut && data.session?.user != null) {
        unawaited(PushNotificationService.instance.syncTokenForCurrentUser());
      }
      unawaited(_syncUserRowFor(data.session?.user));
    });
  }

  static final UserAuthService _instance = UserAuthService._internal();

  /// Accessor for the shared auth service.
  static UserAuthService get instance => _instance;

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authSub;
  User? _currentUser;
  UserRow? _userRow;
  final UserTable _userTable = UserTable();

  /// Currently authenticated user, if any.
  User? get currentUser => _currentUser;

  /// Convenience flag when a session exists.
  bool get isLoggedIn => _currentUser != null;

  /// Resolved row from the public.user table, if fetched.
  UserRow? get userRow => _userRow;

  /// Whether the database indicates a verified email (null when unknown).
  bool? get emailVerified => _userRow?.emailVerified;

  /// True when the current session exists but email is not verified yet.
  bool get requiresEmailVerification =>
      isLoggedIn && (_userRow?.emailVerified == false);

  /// User types that can post QnA replies (admin only).
  static const _qnaReplyAdminTypes = {
    UserType.platform_admin,
    UserType.client_admin,
    UserType.integrated_admin,
    UserType.vendor_admin,
    UserType.super_client_admin,
    UserType.super_integrated_admin,
  };

  /// True when the current user is an admin type that can post QnA replies.
  /// Returns false when [userRow] is null (e.g. not yet loaded).
  bool get isQnaReplyAdmin =>
      _userRow != null && _qnaReplyAdminTypes.contains(_userRow!.type);

  /// Derives a friendly display name prioritizing database username.
  String get displayName =>
      _userRow?.username ??
      _currentUser?.userMetadata?['username'] as String? ??
      _currentUser?.userMetadata?['name'] as String? ??
      _currentUser?.email ??
      'Guest';

  /// Sign in with email + password.
  Future<bool> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _updateUser(response.user);
    return _syncUserRowFor(response.user);
  }

  /// Sign up with email/password plus optional metadata expected by the
  /// database trigger (username, phone, birthdate formatted as YYYY-MM-DD).
  Future<bool> signUp({
    required String email,
    required String password,
    String? username,
    String? phone,
    String? birthdate,
    String? company,
  }) async {
    final metadata = <String, dynamic>{
      if (username != null && username.isNotEmpty) 'username': username,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (birthdate != null && birthdate.isNotEmpty) 'birthdate': birthdate,
      if (company != null && company.isNotEmpty) 'company': company,
    };
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata.isEmpty ? null : metadata,
    );
    _updateUser(response.user);
    final verified = await _syncUserRowFor(response.user);

    // Some environments don't currently persist auth metadata -> public.user
    // (e.g. missing/old DB trigger). For employee signups we must ensure the
    // company is actually stored on the user row.
    if (response.user != null && company != null && company.isNotEmpty) {
      await _ensureCompanyPersisted(
        userId: response.user!.id,
        companyId: company,
      );
      await _syncUserRowFor(response.user);
    }

    return verified;
  }

  Future<void> _ensureCompanyPersisted({
    required String userId,
    required String companyId,
  }) async {
    const maxAttempts = 8;
    const delay = Duration(milliseconds: 350);

    Object? lastError;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final row = await _client
            .from(_userTable.tableName)
            .select('${UserRow.idField}, ${UserRow.companyField}')
            .eq(UserRow.idField, userId)
            .maybeSingle();

        // If the row doesn't exist yet, give the trigger time.
        if (row == null) {
          await Future<void>.delayed(delay);
          continue;
        }

        final currentCompany = row[UserRow.companyField] as String?;
        if (currentCompany != null && currentCompany.isNotEmpty) {
          return;
        }

        await _client
            .from(_userTable.tableName)
            .update({UserRow.companyField: companyId})
            .eq(UserRow.idField, userId);
        return;
      } catch (e) {
        lastError = e;
        await Future<void>.delayed(delay);
      }
    }

    throw AuthException(
      '회사 정보 저장에 실패했습니다. 잠시 후 다시 시도해주세요.\n${lastError ?? ''}',
    );
  }

  /// Logs out the current session.
  Future<void> signOut() async {
    await _client.auth.signOut();
    _updateUser(null);
  }

  /// Sign in using Kakao OAuth.
  ///
  /// Requires Supabase Dashboard provider config + mobile deep-link setup.
  Future<void> signInWithKakao() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.kakao,
      redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
    );
  }

  Future<void> refresh() async {
    await _syncUserRowFor(_currentUser);
  }

  void _updateUser(User? user) {
    _currentUser = user;
    if (user == null) {
      _userRow = null;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  Future<bool> _syncUserRowFor(User? user) async {
    if (user == null) {
      _userRow = null;
      notifyListeners();
      return false;
    }

    try {
      final data = await _client
          .from(_userTable.tableName)
          .select()
          .eq(UserRow.idField, user.id)
          .maybeSingle();
      _userRow = data == null ? null : UserRow.fromJson(data);
    } catch (_) {
      _userRow = null;
    }
    notifyListeners();
    return _userRow?.emailVerified ?? false;
  }

  /// Call to dispose resources if the process needs a clean shutdown.
  void disposeService() {
    _authSub.cancel();
    super.dispose();
  }
}
