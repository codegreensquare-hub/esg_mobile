/// FAQ copy that should open the in-app partnership request flow.
class FaqPartnershipPhraseUtil {
  FaqPartnershipPhraseUtil._();

  /// Admin-facing phrase; every occurrence can be shown as a tappable link.
  static const phrase = '해당 페이지';

  /// Whether [raw] contains [phrase] in user-visible text (not inside markup only).
  static bool answerContainsPhrase(String raw) {
    if (raw.isEmpty) return false;
    return visibleTextForTapBuilding(raw).contains(phrase);
  }

  /// Strips simple HTML so we can render [phrase] with [TextSpan] + recognizers.
  /// Line breaks from `<br>` become `\n`.
  static String visibleTextForTapBuilding(String raw) {
    var s = _decodeBasicHtmlEntities(raw.trim());
    s = s.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      '\n',
    );
    s = s.replaceAll(RegExp(r'<[^>]*>'), '');
    return s;
  }

  static String _decodeBasicHtmlEntities(String s) {
    return s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'");
  }
}
