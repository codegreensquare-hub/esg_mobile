import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';

/// Fonts loaded from Supabase storage, prioritised by importance.
///
/// Essential fonts (Noto Sans KR, EB Garamond) load first using variable font
/// files (~11 MB total). Fallback serif fonts load afterwards.
class FontService {
  static final FontService _instance = FontService._internal();
  static FontService get instance => _instance;
  FontService._internal();

  bool _loaded = false;

  /// Essential fonts that the app needs immediately.
  /// Variable font files cover all weights in a single file.
  static const _essentialFonts = <(String family, String path)>[
    ('Noto Sans KR', 'fonts/Noto_Sans_KR/NotoSansKR-VariableFont_wght.ttf'),
    ('EB Garamond', 'fonts/EB_Garamond/EBGaramond-VariableFont_wght.ttf'),
  ];

  /// Fallback serif fonts — only used for display text fallback.
  /// Load only the Regular weight to keep download small.
  static const _fallbackFonts = <(String family, String path)>[
    ('Source Han Serif KR', 'fonts/Source_Han_Kr/SourceHanSerifK-Regular.otf'),
    (
      'Source Han Serif',
      'fonts/Source_Hans_Serif/SourceHanSerif-Regular.ttc',
    ),
  ];

  /// Load all fonts from Supabase storage. Safe to call multiple times.
  Future<void> loadFonts() async {
    if (_loaded) return;
    _loaded = true;

    // Load essential fonts first (body + headline), then fallbacks.
    await _loadFontList(_essentialFonts);
    // Fire-and-forget: fallback fonts load in the background.
    _loadFontList(_fallbackFonts);
  }

  Future<void> _loadFontList(List<(String, String)> fonts) async {
    await Future.wait(fonts.map((f) => _loadFont(f.$1, f.$2)));
  }

  Future<void> _loadFont(String family, String path) async {
    try {
      final url = getImageLink(bucket.asset, path);
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      final fontLoader = FontLoader(family);
      fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
      await fontLoader.load();
    } catch (e) {
      debugPrint('FontService: failed to load $family from $path: $e');
    }
  }
}
