import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;

class TextStory extends StatelessWidget {
  const TextStory({
    super.key,
    required this.content,
    this.maxLines,
  });

  final String? content;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final document = _quillDocumentFromContent(content);
      if (document == null) {
        return const SizedBox.shrink();
      }

      final plain = document.toPlainText().trim();
      if (plain.isEmpty) {
        return const SizedBox.shrink();
      }

      final theme = Theme.of(context);
      final baseStyle = theme.textTheme.bodyMedium ?? const TextStyle();
      final spans = _documentToTextSpans(
        document,
        baseStyle,
        theme.colorScheme.primary,
      );

      if (spans.isEmpty) {
        return const SizedBox.shrink();
      }

      return Text.rich(
        TextSpan(children: spans),
        maxLines: maxLines,
        overflow: maxLines == null
            ? TextOverflow.visible
            : TextOverflow.ellipsis,
        strutStyle: const StrutStyle(height: 1.3),
      );
    } catch (_) {
      return Text(
        content!,
        maxLines: maxLines,
        overflow: maxLines == null
            ? TextOverflow.visible
            : TextOverflow.ellipsis,
      );
    }
  }
}

flutter_quill.Document? _quillDocumentFromContent(String? content) {
  if (content == null || content.isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(content);
    if (decoded is List<dynamic>) {
      return flutter_quill.Document.fromJson(decoded);
    }
    if (decoded is Map<String, dynamic>) {
      final ops = decoded['ops'];
      if (ops is List<dynamic>) {
        return flutter_quill.Document.fromJson(ops);
      }
    }
  } catch (_) {
    // Ignore and fall back to raw content below.
  }

  if (content.trim().isEmpty) {
    return null;
  }

  return flutter_quill.Document.fromJson([
    {'insert': content},
  ]);
}

List<TextSpan> _documentToTextSpans(
  flutter_quill.Document document,
  TextStyle baseStyle,
  Color linkColor,
) {
  final ops = document.toDelta().toJson();
  final spans = <TextSpan>[];

  for (final op in ops) {
    final insert = op['insert'];
    if (insert is! String || insert.isEmpty) {
      continue;
    }

    final attributes = op['attributes'] is Map<String, dynamic>
        ? op['attributes'] as Map<String, dynamic>
        : null;

    TextStyle style = baseStyle;
    bool underline = false;
    bool strike = false;

    if (attributes != null) {
      if (attributes['bold'] == true) {
        style = style.copyWith(fontWeight: FontWeight.w600);
      }
      if (attributes['italic'] == true) {
        style = style.copyWith(fontStyle: FontStyle.italic);
      }
      if (attributes['underline'] == true) {
        underline = true;
      }
      if (attributes['strike'] == true || attributes['strikethrough'] == true) {
        strike = true;
      }
      if (attributes['color'] is String) {
        final parsed = _colorFromHex(attributes['color'] as String);
        if (parsed != null) {
          style = style.copyWith(color: parsed);
        }
      }
      if (attributes['background'] is String) {
        final bg = _colorFromHex(attributes['background'] as String);
        if (bg != null) {
          style = style.copyWith(backgroundColor: bg);
        }
      }
      if (attributes['link'] is String) {
        underline = true;
        style = style.copyWith(color: linkColor);
      }
    }

    TextDecoration? decoration;
    if (underline && strike) {
      decoration = TextDecoration.combine(
        const [TextDecoration.underline, TextDecoration.lineThrough],
      );
    } else if (underline) {
      decoration = TextDecoration.underline;
    } else if (strike) {
      decoration = TextDecoration.lineThrough;
    }

    if (decoration != null) {
      style = style.copyWith(decoration: decoration);
    }

    spans.add(TextSpan(text: insert, style: style));
  }

  return spans;
}

Color? _colorFromHex(String value) {
  final raw = value.replaceAll('#', '').trim();
  if (raw.isEmpty) {
    return null;
  }

  final normalized = raw.length == 3
      ? raw.split('').map((c) => '$c$c').join()
      : raw;

  final buffer = StringBuffer();
  if (normalized.length == 6) {
    buffer.write('ff');
  }
  buffer.write(normalized);

  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return null;
  }
}
