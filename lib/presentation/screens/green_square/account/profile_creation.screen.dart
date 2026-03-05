import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';

/// Screen for creating a new profile (name input, then create).
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  static const route = '/greensquare/profile-creation';

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          CodeGreenTopHeader(
            initialValue: MainTab.greenSquare,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      '새 프로필 만들기',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Icon(
                      Icons.person_outline,
                      size: 72,
                      color: primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '프로필 이름',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '프로필 4',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('뒤로가기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _handleCreate,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('만들기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }
}
