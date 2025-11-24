/// Generates a public Supabase storage URL for an image.
///
/// [bucket]: The bucket name (e.g., 'mission').
/// [fileName]: The file name (e.g., 'thumbnail.png').
/// [folderPath]: Optional folder path within the bucket.
/// [projectId]: Optional Supabase project ID; defaults to a hardcoded value if null.
String getImageLink(
  String bucket,
  String fileName, {
  String? folderPath,
  String? projectId,
}) {
  const defaultProjectId = 'vmqnzfnupmwcstgbgdgk';
  final effectiveProjectId = projectId ?? defaultProjectId;

  final baseUrl =
      'https://$effectiveProjectId.supabase.co/storage/v1/object/public';

  final fullPath = folderPath != null ? '$folderPath/$fileName' : fileName;

  final finalPath = '$baseUrl/$bucket/$fullPath';

  // In debug mode, you could log this, but since it's Dart, use debugPrint if needed.
  // debugPrint('Generated image link: $finalPath');

  return finalPath;
}
