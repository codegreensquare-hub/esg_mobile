import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  static const int maxProfiles = 4;
  static const List<String> defaultProfiles = [];
  static const List<String> _legacyPlaceholderProfiles = [
    '권세연',
    '프로필 2',
    '프로필 3',
  ];

  static const _profilesKey = 'green_square_profiles';
  static const _selectedProfileIndexKey = 'green_square_selected_profile_index';

  SharedPreferences? _preferences;
  List<String> _profiles = List<String>.from(defaultProfiles);
  int? _selectedProfileIndex;

  List<String> get profiles => List.unmodifiable(_profiles);
  int? get selectedProfileIndex => _selectedProfileIndex;
  String? get selectedProfileName {
    final index = _selectedProfileIndex;
    if (index == null || index < 0 || index >= _profiles.length) return null;
    return _profiles[index];
  }

  Future<void> initialize() async {
    if (_preferences != null) return;
    _preferences = await SharedPreferences.getInstance();
    _loadFromPreferences();
  }

  Future<void> addProfile(String name) async {
    await initialize();

    final trimmedName = name.trim();
    if (trimmedName.isEmpty || _profiles.length >= maxProfiles) return;

    _profiles = [..._profiles, trimmedName];
    await _persistProfiles();
  }

  Future<void> selectProfile(int index) async {
    await initialize();
    if (index < 0 || index >= _profiles.length) return;

    _selectedProfileIndex = index;
    await _persistSelectedProfileIndex();
  }

  Future<void> removeProfiles(Set<int> indices) async {
    await initialize();
    if (indices.isEmpty) return;

    final sortedIndices = indices.toList()..sort((a, b) => b.compareTo(a));
    final removedSelectedProfile =
        _selectedProfileIndex != null &&
        indices.contains(_selectedProfileIndex);

    for (final index in sortedIndices) {
      if (index < 0 || index >= _profiles.length) continue;
      _profiles.removeAt(index);
    }

    if (_profiles.isEmpty) {
      _selectedProfileIndex = null;
    } else if (removedSelectedProfile) {
      _selectedProfileIndex = 0;
    } else if (_selectedProfileIndex != null) {
      final decrement = indices
          .where((index) => index < _selectedProfileIndex!)
          .length;
      _selectedProfileIndex = _selectedProfileIndex! - decrement;
      if (_selectedProfileIndex! >= _profiles.length) {
        _selectedProfileIndex = _profiles.length - 1;
      }
    }

    await _persistProfiles();
    await _persistSelectedProfileIndex();
  }

  void _loadFromPreferences() {
    final hasStoredProfiles = _preferences?.containsKey(_profilesKey) ?? false;
    final storedProfiles = _preferences?.getStringList(_profilesKey);
    _profiles = hasStoredProfiles
        ? List<String>.from(storedProfiles ?? const <String>[])
        : List<String>.from(defaultProfiles);

    final isLegacyPlaceholderOnly =
        _profiles.length == _legacyPlaceholderProfiles.length &&
        _profiles.asMap().entries.every(
          (entry) => entry.value == _legacyPlaceholderProfiles[entry.key],
        );
    if (isLegacyPlaceholderOnly) {
      _profiles = [];
    }

    final storedSelectedProfileIndex = _preferences?.getInt(
      _selectedProfileIndexKey,
    );
    if (storedSelectedProfileIndex != null &&
        storedSelectedProfileIndex >= 0 &&
        storedSelectedProfileIndex < _profiles.length) {
      _selectedProfileIndex = storedSelectedProfileIndex;
    } else {
      _selectedProfileIndex = null;
    }
  }

  Future<void> _persistProfiles() async {
    await _preferences?.setStringList(_profilesKey, _profiles);
  }

  Future<void> _persistSelectedProfileIndex() async {
    final selectedProfileIndex = _selectedProfileIndex;
    if (selectedProfileIndex == null) {
      await _preferences?.remove(_selectedProfileIndexKey);
      return;
    }

    await _preferences?.setInt(_selectedProfileIndexKey, selectedProfileIndex);
  }
}
