import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:esg_mobile/core/utils/faq_partnership_phrase.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/partnership_request.screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// FAQ answers: if visible text includes [FaqPartnershipPhraseUtil.phrase], that
/// text is styled as a link and opens [GreenSquarePartnershipRequestScreen].
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
  TapGestureRecognizer? _partnershipPhraseRecognizer;

  static const _faqLinkGreen = Color(0xFF35C759);
  static const _faqLinkGreenCss = '#35C759';

  @override
  void initState() {
    super.initState();
    _attachPartnershipPhraseRecognizer();
  }

  @override
  void didUpdateWidget(covariant FaqCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.answer != widget.answer) {
      _attachPartnershipPhraseRecognizer();
    }
  }

  void _attachPartnershipPhraseRecognizer() {
    _partnershipPhraseRecognizer?.dispose();
    _partnershipPhraseRecognizer = TapGestureRecognizer()
      ..onTap = _openPartnershipRequest;
  }

  @override
  void dispose() {
    _partnershipPhraseRecognizer?.dispose();
    super.dispose();
  }

  void _openPartnershipRequest() {
    if (!mounted) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const GreenSquarePartnershipRequestScreen(),
      ),
    );
  }

  /// [TapGestureRecognizer] works reliably here; [WidgetSpan] + [GestureDetector] often does not.
  Widget _buildAnswerWithTappablePhrase({
    required TextStyle baseStyle,
    required TextStyle linkStyle,
    required String visibleText,
    required TapGestureRecognizer recognizer,
  }) {
    final phrase = FaqPartnershipPhraseUtil.phrase;
    final parts = visibleText.split(phrase);
    final children = <InlineSpan>[];

    for (var i = 0; i < parts.length; i++) {
      children.add(TextSpan(text: parts[i], style: baseStyle));
      if (i < parts.length - 1) {
        children.add(
          TextSpan(
            text: phrase,
            style: linkStyle,
            recognizer: recognizer,
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: children),
      style: baseStyle,
    );
  }

  Future<bool> _onTapExternalUrl(String url) async {
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

  Widget _buildAnswerBody(ThemeData theme) {
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
          fontFamily: 'Noto Sans KR',
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(height: 1.6);

    final linkStyle = baseStyle.copyWith(
      color: _faqLinkGreen,
      decoration: TextDecoration.underline,
      decorationColor: _faqLinkGreen,
    );

    final recognizer = _partnershipPhraseRecognizer;
    if (recognizer != null &&
        FaqPartnershipPhraseUtil.answerContainsPhrase(widget.answer)) {
      final visible = FaqPartnershipPhraseUtil.visibleTextForTapBuilding(
        widget.answer,
      );
      return _buildAnswerWithTappablePhrase(
        baseStyle: baseStyle,
        linkStyle: linkStyle,
        visibleText: visible,
        recognizer: recognizer,
      );
    }

    return HtmlWidget(
      widget.answer,
      onTapUrl: _onTapExternalUrl,
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'color': _faqLinkGreenCss,
            'text-decoration': 'underline',
          };
        }
        return null;
      },
      textStyle: baseStyle,
    );
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
            child: _buildAnswerBody(theme),
          ),
        ],
        Divider(height: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}
