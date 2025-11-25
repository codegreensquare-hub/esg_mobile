import 'dart:async';

import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission_participation.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission_photo_animation_completion.dart';
import 'package:esg_mobile/presentation/screens/green_square/mission_participation_success.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/mission_photo_preview.screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MissionParticipationException implements Exception {
  const MissionParticipationException(this.message);

  final String message;

  @override
  String toString() => 'MissionParticipationException: $message';
}

class MissionParticipationService {
  MissionParticipationService._internal({
    SupabaseClient? client,
    ImagePicker? imagePicker,
  }) : _client = client ?? Supabase.instance.client,
       _picker = imagePicker ?? ImagePicker(),
       _participationTable = MissionParticipationTable(),
       _completionTable = MissionPhotoAnimationCompletionTable();

  static final MissionParticipationService _instance =
      MissionParticipationService._internal();

  static MissionParticipationService get instance => _instance;

  final SupabaseClient _client;
  final ImagePicker _picker;
  final MissionParticipationTable _participationTable;
  final MissionPhotoAnimationCompletionTable _completionTable;

  Future<void> startParticipationFlow({
    required BuildContext context,
    required MissionRow mission,
  }) async {
    try {
      final source = await _chooseImageSource(context);
      if (source == null || !context.mounted) {
        return;
      }

      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (!context.mounted) {
        return;
      }

      if (file == null) {
        return;
      }

      final bool? confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => MissionPhotoPreviewScreen(imagePath: file.path),
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      await _createParticipation(mission);
      final completionPhotos = await _fetchCompletionPhotos(mission.id);

      if (!context.mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MissionParticipationSuccessScreen(
            mission: mission,
            completionPhotos: completionPhotos,
          ),
        ),
      );
    } on MissionParticipationException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션 참여 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  Future<ImageSource?> _chooseImageSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('앨범에서 선택'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createParticipation(MissionRow mission) async {
    final userId = UserAuthService.instance.currentUser?.id;
    if (userId == null) {
      throw const MissionParticipationException('로그인이 필요한 기능입니다.');
    }

    await _client
        .from(_participationTable.tableName)
        .insert({
          MissionParticipationRow.participatedByField: userId,
          MissionParticipationRow.missionField: mission.id,
        })
        .select()
        .single();
  }

  Future<List<MissionPhotoAnimationCompletionRow>> _fetchCompletionPhotos(
    String missionId,
  ) async {
    final List<dynamic> response = await _client
        .from(_completionTable.tableName)
        .select()
        .eq(MissionPhotoAnimationCompletionRow.missionField, missionId)
        .order(MissionPhotoAnimationCompletionRow.orderField);

    return response
        .map((json) => MissionPhotoAnimationCompletionRow.fromJson(json))
        .toList();
  }
}
