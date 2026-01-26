import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';

class FontService {
  static final FontService _instance = FontService._internal();
  static FontService get instance => _instance;
  FontService._internal();

  String _getFamily(String fontName) {
    if (fontName.startsWith('EBGaramond')) return 'EB Garamond';
    if (fontName.startsWith('NotoSansKR')) return 'Noto Sans KR';
    if (fontName.startsWith('SourceHanSerifK')) return 'Source Han Serif KR';
    if (fontName.startsWith('SourceHanSerif')) return 'Source Han Serif';
    return 'Unknown';
  }

  Future<void> loadFonts() async {
    final fontPaths = <String, List<String>>{};
    for (final entry in assetFolderPath.entries) {
      final fontName = entry.key;
      final folder = entry.value;
      if (folder.startsWith('fonts/')) {
        final family = _getFamily(fontName);
        final path = '$folder/$fontName';
        fontPaths.putIfAbsent(family, () => []).add(path);
      }
    }

    for (final entry in fontPaths.entries) {
      final family = entry.key;
      final paths = entry.value;
      final fontLoader = FontLoader(family);
      final futures = paths.map((path) async {
        final url = getImageLink(bucket.asset, path);
        final file = await DefaultCacheManager().getSingleFile(url);
        return await file.readAsBytes();
      });
      final bytesList = await Future.wait(futures);
      for (final bytes in bytesList) {
        fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await fontLoader.load();
    }
  }

  Future<void> loadFontEntry(String family, String path) async {
    final fontLoader = FontLoader(family);
    try {
      final url = getImageLink(bucket.asset, path);
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
      await fontLoader.load();
    } catch (e) {
      print('Error loading font $family from $path: $e');
    }
  }
}
