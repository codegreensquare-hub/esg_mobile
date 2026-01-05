import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileResult {
  const EditProfileResult({
    required this.username,
    this.photo,
  });

  final String username;
  final XFile? photo;
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({
    super.key,
    required this.initialUsername,
  });

  final String initialUsername;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  XFile? _photo;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (!mounted) return;
    if (file == null) return;

    setState(() {
      _photo = file;
    });
  }

  void _save() {
    final username = _nameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }

    Navigator.of(context).pop(
      EditProfileResult(username: username, photo: _photo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '프로필 수정',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_outlined),
              label: Text(_photo == null ? '사진 변경' : '사진 선택됨'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
