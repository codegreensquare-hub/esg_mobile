import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  static const int maxProfiles = 4;
  static const int maxCustomProfiles = maxProfiles - 1;
  static const List<String> defaultProfiles = [];
  static const _tableName = 'user_profile';
  static const _selectedProfileIdKey = 'green_square_selected_profile_id';
  static const _mainProfileSelectionValue = '__main_profile__';

  final SupabaseClient _client = Supabase.instance.client;
  SharedPreferences? _preferences;
  List<String> _profiles = List<String>.from(defaultProfiles);
  List<String> _profileIds = [];
  int? _selectedProfileIndex;
  bool _isMainProfileSelected = false;
  String? _initializedUserId;
  List<String> _cachedProfiles = List<String>.from(defaultProfiles);
  int? _cachedSelectedProfileIndex;
  bool _cachedIsMainProfileSelected = false;

  List<String> get profiles => List.unmodifiable(_profiles);
  int? get selectedProfileIndex => _selectedProfileIndex;
  bool get isMainProfileSelected => _isMainProfileSelected;
  String? get selectedProfileId {
    final index = _selectedProfileIndex;
    if (index == null || index < 0 || index >= _profileIds.length) return null;
    return _profileIds[index];
  }

  List<String> get cachedProfiles => List.unmodifiable(_cachedProfiles);
  int? get cachedSelectedProfileIndex => _cachedSelectedProfileIndex;
  bool get cachedIsMainProfileSelected => _cachedIsMainProfileSelected;
  String? get selectedProfileName {
    final index = _selectedProfileIndex;
    if (index == null || index < 0 || index >= _profiles.length) return null;
    return _profiles[index];
  }

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _initializedUserId = null;
      _profiles = List<String>.from(defaultProfiles);
      _profileIds = [];
      _selectedProfileIndex = null;
      _isMainProfileSelected = false;
      _cachedProfiles = List<String>.from(defaultProfiles);
      _cachedSelectedProfileIndex = null;
      _cachedIsMainProfileSelected = false;
      return;
    }

    if (_initializedUserId == userId) return;

    _initializedUserId = userId;
    await _reloadProfiles(userId);
  }

  Future<void> addProfile(String name) async {
    await initialize();
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ProfileServiceException('로그인이 필요합니다.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    if (_profiles.length >= maxCustomProfiles) {
      throw const ProfileServiceException('프로필은 최대 4개까지 만들 수 있습니다.');
    }

    final response = await _client
        .from(_tableName)
        .insert({
          'user': userId,
          'name': trimmedName,
        })
        .select('id, name, created_at')
        .single();

    final insertedRows = _normalizeProfileRows([response]);
    if (insertedRows.isEmpty) return;

    final insertedRow = insertedRows.first;
    _profileIds = [..._profileIds, insertedRow['id'] as String];
    _profiles = [..._profiles, insertedRow['name'] as String];
    _cachedProfiles = List<String>.from(_profiles);
    _cachedSelectedProfileIndex = _selectedProfileIndex;
  }

  Future<void> selectProfile(int index) async {
    await initialize();
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ProfileServiceException('로그인이 필요합니다.');
    }
    if (index < 0 || index >= _profiles.length) return;

    final selectedProfileId = _profileIds[index];
    await _preferences?.setString(_selectedProfileIdKey, selectedProfileId);
    _selectedProfileIndex = index;
    _isMainProfileSelected = false;
    _cachedSelectedProfileIndex = index;
    _cachedIsMainProfileSelected = false;
  }

  Future<void> selectMainProfile() async {
    await initialize();
    await _preferences?.setString(
      _selectedProfileIdKey,
      _mainProfileSelectionValue,
    );
    _selectedProfileIndex = null;
    _isMainProfileSelected = true;
    _cachedSelectedProfileIndex = null;
    _cachedIsMainProfileSelected = true;
  }

  Future<void> removeProfiles(Set<int> indices) async {
    await initialize();
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ProfileServiceException('로그인이 필요합니다.');
    }
    if (indices.isEmpty) return;

    final rows = await _fetchProfileRows(userId);
    final selectedIds = indices
        .where((index) => index >= 0 && index < rows.length)
        .map((index) => rows[index]['id'] as String)
        .toList();
    if (selectedIds.isEmpty) return;

    final selectedProfileId = _preferences?.getString(_selectedProfileIdKey);

    await _client.from(_tableName).delete().inFilter('id', selectedIds);

    if (selectedProfileId != null && selectedIds.contains(selectedProfileId)) {
      await _preferences?.setString(
        _selectedProfileIdKey,
        _mainProfileSelectionValue,
      );
    }

    await _reloadProfiles(userId);
  }

  Future<void> refresh() async {
    _preferences ??= await SharedPreferences.getInstance();

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _profiles = List<String>.from(defaultProfiles);
      _profileIds = [];
      _selectedProfileIndex = null;
      _isMainProfileSelected = false;
      _initializedUserId = null;
      _cachedProfiles = List<String>.from(defaultProfiles);
      _cachedSelectedProfileIndex = null;
      _cachedIsMainProfileSelected = false;
      return;
    }

    _initializedUserId = userId;
    await _reloadProfiles(userId);
  }

  Future<void> _reloadProfiles(String userId) async {
    final rows = await _fetchProfileRows(userId);

    _profileIds = rows.map((row) => row['id'] as String).toList();
    _profiles = rows.map((row) => row['name'] as String).toList();

    final selectedProfileId = _preferences?.getString(_selectedProfileIdKey);
    final isMainProfileSelected =
        selectedProfileId == _mainProfileSelectionValue;
    final selectedIndex = selectedProfileId == null || isMainProfileSelected
        ? -1
        : _profileIds.indexOf(selectedProfileId);
    _selectedProfileIndex = selectedIndex >= 0 ? selectedIndex : null;
    _isMainProfileSelected = isMainProfileSelected;
    _cachedProfiles = List<String>.from(_profiles);
    _cachedSelectedProfileIndex = _selectedProfileIndex;
    _cachedIsMainProfileSelected = _isMainProfileSelected;
  }

  Future<List<Map<String, dynamic>>> _fetchProfileRows(String userId) async {
    final response = await _client
        .from(_tableName)
        .select('id, name, created_at')
        .eq('user', userId);

    return _normalizeProfileRows(response.whereType<Map<String, dynamic>>());
  }

  List<Map<String, dynamic>> _normalizeProfileRows(
    Iterable<Map<String, dynamic>> rows,
  ) {
    final normalizedRows =
        rows
            .map(
              (row) => {
                ...row,
                'name': ((row['name'] as String?) ?? '').trim(),
                'created_at': _parseCreatedAt(row['created_at']),
              },
            )
            .where((row) => (row['name'] as String).isNotEmpty)
            .toList()
          ..sort((left, right) {
            final createdAtComparison = (left['created_at'] as DateTime)
                .compareTo(
                  right['created_at'] as DateTime,
                );
            if (createdAtComparison != 0) return createdAtComparison;

            return (left['id'] as String).compareTo(right['id'] as String);
          });

    return normalizedRows;
  }

  DateTime _parseCreatedAt(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class ProfileServiceException implements Exception {
  const ProfileServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
