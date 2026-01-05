import 'dart:typed_data';

import 'package:esg_mobile/data/models/supabase/tables/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  final SupabaseClient _client = Supabase.instance.client;

  String get _photoBucket =>
      (dotenv.env['SUPABASE_USER_PHOTO_BUCKET'] ?? '').trim().isNotEmpty
      ? dotenv.env['SUPABASE_USER_PHOTO_BUCKET']!.trim()
      : 'user';

  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    await _client
        .from(UserTable().tableName)
        .update({
          UserRow.usernameField: username,
        })
        .eq(UserRow.idField, userId);
  }

  Future<void> updateProfilePhoto({
    required String userId,
    required XFile file,
  }) async {
    final Uint8List bytes = await file.readAsBytes();

    final bucket = _photoBucket;
    final folderPath = 'users/$userId';
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$folderPath/$fileName';

    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      await _client
          .from(UserTable().tableName)
          .update({
            UserRow.photoBucketField: bucket,
            UserRow.photoFolderPathField: folderPath,
            UserRow.photoFileNameField: fileName,
          })
          .eq(UserRow.idField, userId);
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
      rethrow;
    }
  }
}
