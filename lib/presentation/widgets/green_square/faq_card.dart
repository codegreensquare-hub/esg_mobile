import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqCard extends StatefulWidget {
  const FaqCard({
    super.key,
    required this.question,
    required this.answer,
    this.showDivider = true,
  });

  final String question;
  final String answer;
  final bool showDivider;

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;

  Future<bool> _onTapUrl(String url) async {
    // Ensure the URL has a scheme — HtmlWidget may pass bare hostnames.
    var normalized = url.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://') &&
        !normalized.startsWith('mailto:') &&
        !normalized.startsWith('tel:')) {
      normalized = 'https://$normalized';
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        debugPrint('FaqCard: canLaunchUrl returned false for $uri');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('링크를 열 수 없습니다. 다시 시도해주세요.'),
            ),
          );
        }
        return false;
      }

      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('링크를 열 수 없습니다. 다시 시도해주세요.'),
          ),
        );
      }
      return launched;
    } catch (e) {
      debugPrint('FaqCard: launchUrl error for $uri: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('링크를 열 수 없습니다.'),
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Q. ${widget.question}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Noto Sans KR',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: HtmlWidget(
              widget.answer,
              onTapUrl: _onTapUrl,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontFamily: 'Noto Sans KR',
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        Divider(height: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}
