import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';

/// Mock upper-level departments (for local state only).
const List<String> _mockUpperDepartments = [
  '마케팅팀',
  '기획팀',
  '인사팀',
  '개발팀',
];

/// Mock lower-level departments per upper (for local state only).
const Map<String, List<String>> _mockLowerDepartments = {
  '마케팅팀': ['퍼포먼스마케팅팀', '브랜드마케팅팀', '광고팀'],
  '기획팀': ['전략기획팀', '사업기획팀'],
  '인사팀': ['채용팀', '교육팀'],
  '개발팀': ['프론트엔드팀', '백엔드팀', '인프라팀'],
};

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
  String? _selectedUpper;
  String? _selectedLower;

  @override
  void initState() {
    super.initState();
    _selectedUpper = widget.upperDepartmentName;
    _selectedLower = widget.lowerDepartmentName;
  }

  List<String> get _lowerOptions {
    if (_selectedUpper == null) return [];
    return _mockLowerDepartments[_selectedUpper] ?? [];
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
                    child: widget.affiliationName != null
                        ? Text.rich(
                            TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: '소속기관명 : '),
                                TextSpan(
                                  text: widget.affiliationName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (widget.affiliationName != null) const SizedBox(height: 4),
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
                    value: _selectedUpper,
                    hint: '선택',
                    items: _mockUpperDepartments,
                    onChanged: (v) {
                      setState(() {
                        _selectedUpper = v;
                        if (_selectedLower != null &&
                            !_lowerOptions.contains(_selectedLower)) {
                          _selectedLower = null;
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
                    value: _selectedLower,
                    hint: '선택',
                    items: _lowerOptions,
                    onChanged: (v) => setState(() => _selectedLower = v),
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
              onPressed: () {
                // TODO: save changes
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('수정하기'),
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
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value != null && items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface),
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, style: theme.textTheme.bodyLarge),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
