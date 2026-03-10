import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum _AttachmentSource { album, files }

class GreenSquareAttachmentButton extends StatefulWidget {
  const GreenSquareAttachmentButton({
    super.key,
    this.placeholderLabel = '파일을 업로드해 주세요.',
    this.textStyle,
  });

  final String placeholderLabel;
  final TextStyle? textStyle;

  @override
  State<GreenSquareAttachmentButton> createState() =>
      _GreenSquareAttachmentButtonState();
}

class _GreenSquareAttachmentButtonState
    extends State<GreenSquareAttachmentButton> {
  final _imagePicker = ImagePicker();
  String? _selectedAttachmentName;

  static const _foregroundColor = Color(0xFF878583);

  Future<void> _handleSourceSelected(_AttachmentSource source) async {
    switch (source) {
      case _AttachmentSource.album:
        await _pickFromAlbum();
      case _AttachmentSource.files:
        await _pickFromFiles();
    }
  }

  Future<void> _pickFromAlbum() async {
    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (!mounted || selectedImage == null) return;

      setState(() {
        _selectedAttachmentName = selectedImage.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앨범에서 파일을 불러오지 못했습니다.')),
      );
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final selectedFile = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (!mounted || selectedFile == null || selectedFile.files.isEmpty) {
        return;
      }

      setState(() {
        _selectedAttachmentName = selectedFile.files.single.name;
      });
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('파일 선택기를 사용하려면 앱을 완전히 다시 실행해 주세요.'),
        ),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? '파일을 불러오지 못했습니다.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('파일을 불러오지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: PopupMenuButton<_AttachmentSource>(
        tooltip: '',
        onSelected: _handleSourceSelected,
        itemBuilder: (context) => const [
          PopupMenuItem<_AttachmentSource>(
            value: _AttachmentSource.album,
            child: Text('앨범에서 열기'),
          ),
          PopupMenuItem<_AttachmentSource>(
            value: _AttachmentSource.files,
            child: Text('파일에서 열기'),
          ),
        ],
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_file,
                  size: 20,
                  color: _foregroundColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedAttachmentName ?? widget.placeholderLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        widget.textStyle?.copyWith(color: _foregroundColor) ??
                        const TextStyle(
                          color: _foregroundColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
