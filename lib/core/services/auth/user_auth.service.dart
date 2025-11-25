import 'dart:async';

import 'package:esg_mobile/data/models/supabase/tables/user.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service that exposes the current Supabase user plus helper auth
/// operations. Widgets can listen to [UserAuthService.instance] for changes.
class UserAuthService extends ChangeNotifier {
  UserAuthService._internal() : _client = Supabase.instance.client {
    _currentUser = _client.auth.currentUser;
    unawaited(_syncUserRowFor(_currentUser));
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user);
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
  }) async {
    final metadata = <String, dynamic>{
      if (username != null && username.isNotEmpty) 'username': username,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (birthdate != null && birthdate.isNotEmpty) 'birthdate': birthdate,
    };
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata.isEmpty ? null : metadata,
    );
    _updateUser(response.user);
    return _syncUserRowFor(response.user);
  }

  /// Logs out the current session.
  Future<void> signOut() async {
    await _client.auth.signOut();
    _updateUser(null);
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
