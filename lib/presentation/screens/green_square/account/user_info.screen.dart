import 'dart:convert';

import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User's information page (내 정보 보기).
/// Displays affiliation, name, upper/lower department and an Edit action.
class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({
    super.key,
    required this.userName,
    this.affiliationName,
    this.activeProfileCount = 0,
    this.upperDepartmentName,
    this.lowerDepartmentName,
  });

  final String userName;
  final String? affiliationName;
  final int activeProfileCount;
  final String? upperDepartmentName;
  final String? lowerDepartmentName;

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  static const _departmentCacheKeyPrefix =
      'green_square_user_department_selection';

  final SupabaseClient _client = Supabase.instance.client;

  String? _selectedUpperId;
  String? _selectedLowerId;
  String? _companyName;
  List<_DepartmentOption> _upperDepartments = const [];
  Map<String, List<_DepartmentOption>> _lowerDepartmentsByUpperId = const {};
  bool _isLoadingDepartments = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _companyName = widget.affiliationName;
    _restoreDepartmentCache();
    _loadDepartments();
  }

  String _departmentCacheKey(String userId) =>
      '$_departmentCacheKeyPrefix:$userId';

  Future<void> _restoreDepartmentCache() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final preferences = await SharedPreferences.getInstance();
      final rawCache = preferences.getString(_departmentCacheKey(userId));
      if (rawCache == null) return;

      final cachedData = _DepartmentCache.fromJson(
        jsonDecode(rawCache) as Map<String, dynamic>,
      );

      if (!mounted) return;
      setState(() {
        _companyName = cachedData.companyName ?? _companyName;
        _selectedUpperId = cachedData.selectedUpperId;
        _selectedLowerId = cachedData.selectedLowerId;
        _upperDepartments = cachedData.upperDepartments;
        _lowerDepartmentsByUpperId = cachedData.lowerDepartmentsByUpperId;
      });
    } catch (_) {}
  }

  Future<void> _saveDepartmentCache({
    required String userId,
    String? companyName,
    String? upperDepartmentId,
    String? lowerDepartmentId,
    List<_DepartmentOption>? upperDepartments,
    Map<String, List<_DepartmentOption>>? lowerDepartmentsByUpperId,
  }) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final cache = _DepartmentCache(
        companyName: companyName ?? _companyName,
        selectedUpperId: upperDepartmentId,
        selectedLowerId: lowerDepartmentId,
        upperDepartments: upperDepartments ?? _upperDepartments,
        lowerDepartmentsByUpperId:
            lowerDepartmentsByUpperId ?? _lowerDepartmentsByUpperId,
      );
      await preferences.setString(
        _departmentCacheKey(userId),
        jsonEncode(cache.toJson()),
      );
    } catch (_) {}
  }

  List<_DepartmentOption> get _lowerOptions {
    final selectedUpperId = _selectedUpperId;
    if (selectedUpperId == null) return const [];
    return _lowerDepartmentsByUpperId[selectedUpperId] ?? const [];
  }

  Future<void> _loadDepartments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoadingDepartments = false);
      return;
    }

    try {
      final userRow = await _client
          .from('user')
          .select('company, department, sub_department')
          .eq('id', userId)
          .single();

      final companyId = userRow['company'] as String?;
      final selectedUpperId = userRow['department'] as String?;
      final selectedLowerId = userRow['sub_department'] as String?;

      if (companyId == null) {
        await _saveDepartmentCache(
          userId: userId,
          companyName: null,
          upperDepartmentId: null,
          lowerDepartmentId: null,
          upperDepartments: const [],
          lowerDepartmentsByUpperId: const {},
        );
        if (!mounted) return;
        setState(() {
          _selectedUpperId = null;
          _selectedLowerId = null;
          _upperDepartments = const [];
          _lowerDepartmentsByUpperId = const {};
          _isLoadingDepartments = false;
        });
        return;
      }

      final companyRow = await _client
          .from('company')
          .select('name')
          .eq('id', companyId)
          .single();
      final departmentsResponse = await _client
          .from('department')
          .select('id, name')
          .eq('company', companyId)
          .order('name');

      final upperDepartments = departmentsResponse
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => _DepartmentOption(
              id: row['id'] as String,
              name: (row['name'] as String?) ?? '',
            ),
          )
          .where((option) => option.name.isNotEmpty)
          .toList();

      final departmentIds = upperDepartments
          .map((option) => option.id)
          .toList();
      final lowerDepartmentsResponse = departmentIds.isEmpty
          ? const <dynamic>[]
          : await _client
                .from('sub_department')
                .select('id, name, department')
                .inFilter('department', departmentIds)
                .order('name');

      final lowerDepartmentsByUpperId = lowerDepartmentsResponse
          .whereType<Map<String, dynamic>>()
          .fold<Map<String, List<_DepartmentOption>>>({}, (map, row) {
            final departmentId = row['department'] as String?;
            final id = row['id'] as String?;
            final name = row['name'] as String?;
            if (departmentId == null ||
                id == null ||
                name == null ||
                name.isEmpty) {
              return map;
            }

            final items = map[departmentId] ?? <_DepartmentOption>[];
            map[departmentId] = [
              ...items,
              _DepartmentOption(id: id, name: name),
            ];
            return map;
          });

      await _saveDepartmentCache(
        userId: userId,
        companyName: companyRow['name'] as String? ?? widget.affiliationName,
        upperDepartmentId: selectedUpperId,
        lowerDepartmentId: selectedLowerId,
        upperDepartments: upperDepartments,
        lowerDepartmentsByUpperId: lowerDepartmentsByUpperId,
      );

      if (!mounted) return;
      setState(() {
        _companyName = companyRow['name'] as String? ?? widget.affiliationName;
        _selectedUpperId = selectedUpperId;
        _selectedLowerId = selectedLowerId;
        _upperDepartments = upperDepartments;
        _lowerDepartmentsByUpperId = lowerDepartmentsByUpperId;
        _isLoadingDepartments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingDepartments = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('부서 정보를 불러오지 못했습니다.')),
      );
    }
  }

  Future<void> _handleSave() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      await _client
          .from('user')
          .update({
            'department': _selectedUpperId,
            'sub_department': _selectedLowerId,
          })
          .eq('id', userId);

      await _saveDepartmentCache(
        userId: userId,
        companyName: _companyName,
        upperDepartmentId: _selectedUpperId,
        lowerDepartmentId: _selectedLowerId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('소속 정보가 수정되었습니다.')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소속 정보를 수정하지 못했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CodeGreenTopHeader(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: theme.colorScheme.onPrimary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      '내 정보 보기',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _companyName != null
                        ? Text.rich(
                            TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: '소속기관명 : '),
                                TextSpan(
                                  text: _companyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (_companyName != null) const SizedBox(height: 4),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: '활성화된 프로필 : '),
                          TextSpan(
                            text: '${widget.activeProfileCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: '개'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '이름',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    color: Colors.white,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.userName,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '상위 소속 부서 *',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DepartmentDropdownField(
                    value: _selectedUpperId,
                    hint: '선택',
                    items: _upperDepartments,
                    enabled:
                        !_isLoadingDepartments && _upperDepartments.isNotEmpty,
                    onChanged: (v) {
                      setState(() {
                        _selectedUpperId = v;
                        if (_selectedLowerId != null &&
                            !_lowerOptions.any(
                              (option) => option.id == _selectedLowerId,
                            )) {
                          _selectedLowerId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '하위 소속 부서 *',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DepartmentDropdownField(
                    value: _selectedLowerId,
                    hint: '선택',
                    items: _lowerOptions,
                    enabled: !_isLoadingDepartments && _lowerOptions.isNotEmpty,
                    onChanged: (v) => setState(() => _selectedLowerId = v),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoadingDepartments || _isSaving
                  ? null
                  : _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: onPrimary,
                disabledBackgroundColor: Colors.grey.shade400,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_isSaving ? '수정 중...' : '수정하기'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartmentDropdownField extends StatelessWidget {
  const _DepartmentDropdownField({
    this.value,
    required this.hint,
    required this.items,
    this.enabled = true,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<_DepartmentOption> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value != null && items.any((item) => item.id == value)
              ? value
              : null,
          hint: Text(
            hint,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          disabledHint: Text(
            hint,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.name, style: theme.textTheme.bodyLarge),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

class _DepartmentOption {
  const _DepartmentOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory _DepartmentOption.fromJson(Map<String, dynamic> json) {
    return _DepartmentOption(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class _DepartmentCache {
  const _DepartmentCache({
    required this.companyName,
    required this.selectedUpperId,
    required this.selectedLowerId,
    required this.upperDepartments,
    required this.lowerDepartmentsByUpperId,
  });

  final String? companyName;
  final String? selectedUpperId;
  final String? selectedLowerId;
  final List<_DepartmentOption> upperDepartments;
  final Map<String, List<_DepartmentOption>> lowerDepartmentsByUpperId;

  factory _DepartmentCache.fromJson(Map<String, dynamic> json) {
    final upperDepartments =
        ((json['upper_departments'] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_DepartmentOption.fromJson)
            .where((option) => option.id.isNotEmpty && option.name.isNotEmpty)
            .toList();

    final lowerMap =
        ((json['lower_departments'] as Map<String, dynamic>?) ??
                const <String, dynamic>{})
            .map(
              (key, value) => MapEntry(
                key,
                ((value as List<dynamic>?) ?? const [])
                    .whereType<Map<String, dynamic>>()
                    .map(_DepartmentOption.fromJson)
                    .where(
                      (option) =>
                          option.id.isNotEmpty && option.name.isNotEmpty,
                    )
                    .toList(),
              ),
            );

    return _DepartmentCache(
      companyName: json['company_name'] as String?,
      selectedUpperId: json['selected_upper_id'] as String?,
      selectedLowerId: json['selected_lower_id'] as String?,
      upperDepartments: upperDepartments,
      lowerDepartmentsByUpperId: lowerMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'selected_upper_id': selectedUpperId,
      'selected_lower_id': selectedLowerId,
      'upper_departments': upperDepartments
          .map((option) => option.toJson())
          .toList(),
      'lower_departments': lowerDepartmentsByUpperId.map(
        (key, value) => MapEntry(
          key,
          value.map((option) => option.toJson()).toList(),
        ),
      ),
    };
  }
}
