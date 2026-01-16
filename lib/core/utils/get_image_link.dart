/// Generates a public Supabase storage URL for an image.
///
/// [bucket]: The bucket name (e.g., 'mission').
/// [fileName]: The file name (e.g., 'thumbnail.png').
/// [folderPath]: Optional folder path within the bucket.
/// Requires Supabase to be initialized (uses the configured client).

import 'package:supabase_flutter/supabase_flutter.dart';

String getImageLink(
  String bucket,
  String fileName, {
  String? folderPath,
}) {
  final fullPath = folderPath != null ? '$folderPath/$fileName' : fileName;

  return Supabase.instance.client.storage.from(bucket).getPublicUrl(fullPath);
}
