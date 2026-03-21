import 'dart:async';
import 'dart:typed_data';

import 'package:esg_mobile/core/config/maxParticipation.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/profile.service.dart';
import 'package:esg_mobile/core/utils/image_phash.dart';
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

  final StreamController<void> _participationSubmittedController =
      StreamController<void>.broadcast();

  final SupabaseClient _client;
  final ImagePicker _picker;
  final MissionParticipationTable _participationTable;
  final MissionPhotoAnimationCompletionTable _completionTable;

  Stream<void> get participationSubmittedStream =>
      _participationSubmittedController.stream;

  Future<void> startParticipationFlow({
    required BuildContext context,
    required MissionRow mission,
    VoidCallback? onSuccess,
  }) async {
    VoidCallback? dismissLoading;
    try {
      final count = await getTodayParticipationCount();

      if (count >= MAX_PARTICIPATION && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '오늘 미션 참여 한도에 도달했습니다. 내일 다시 시도해 주세요.',
            ),
          ),
        );
        return;
      }

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

      final Uint8List bytes = await file.readAsBytes();
      if (!context.mounted) {
        return;
      }

      final bool? confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => MissionPhotoPreviewScreen(imageBytes: bytes),
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      dismissLoading = _showLoadingDialog(context);

      // Compute perceptual hash and upload in parallel
      final phashFuture = ImagePhash.compute(bytes).catchError((_) => '');
      final uploadFuture = _uploadPhoto(bytes: bytes, mission: mission);
      final results = await Future.wait([phashFuture, uploadFuture]);
      final imagePhash = results[0] as String;
      final uploadedPhoto = results[1]
          as ({String bucket, String folderPath, String fileName});

      await _createParticipation(
        mission,
        photo: uploadedPhoto,
        imagePhash: imagePhash.isNotEmpty ? imagePhash : null,
      );
      _participationSubmittedController.add(null);
      onSuccess?.call();
      final completionPhotos = await _fetchCompletionPhotos(mission.id);

      dismissLoading();
      dismissLoading = null;

      if (!context.mounted) {
        return;
      }

      // Close the mission detail dialog first
      Navigator.of(context).pop();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MissionParticipationSuccessScreen(
            mission: mission,
            completionPhotos: completionPhotos,
          ),
        ),
      );
    } on MissionParticipationException catch (error) {
      dismissLoading?.call();
      dismissLoading = null;
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      dismissLoading?.call();
      dismissLoading = null;
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션 참여 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  VoidCallback _showLoadingDialog(BuildContext context) {
    bool closed = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ).whenComplete(() => closed = true);
    return () {
      if (closed || !context.mounted) {
        return;
      }
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
        closed = true;
      }
    };
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

  Future<void> _createParticipation(
    MissionRow mission, {
    required ({String bucket, String folderPath, String fileName}) photo,
    String? imagePhash,
  }) async {
    final userId = UserAuthService.instance.currentUser?.id;
    if (userId == null) {
      throw const MissionParticipationException('로그인이 필요한 기능입니다.');
    }

    final profileService = ProfileService.instance;
    await profileService.initialize();
    final profileUsed = profileService.isMainProfileSelected
        ? null
        : profileService.selectedProfileId;
    var userRow = UserAuthService.instance.userRow;
    if (userRow == null) {
      await UserAuthService.instance.refresh();
      userRow = UserAuthService.instance.userRow;
    }

    await _client
        .from(_participationTable.tableName)
        .insert({
          MissionParticipationRow.participatedByField: userId,
          MissionParticipationRow.missionField: mission.id,
          MissionParticipationRow.photoBucketField: photo.bucket,
          MissionParticipationRow.photoFolderPathField: photo.folderPath,
          MissionParticipationRow.photoFileNameField: photo.fileName,
          MissionParticipationRow.profileUsedField: profileUsed,
          MissionParticipationRow.departmentField: userRow?.department,
          MissionParticipationRow.subDepartmentField: userRow?.subDepartment,
          if (imagePhash != null) 'image_phash': imagePhash,
        })
        .select()
        .single();
  }

  Future<({String bucket, String folderPath, String fileName})> _uploadPhoto({
    required Uint8List bytes,
    required MissionRow mission,
  }) async {
    final userId = UserAuthService.instance.currentUser?.id;
    if (userId == null) {
      throw const MissionParticipationException('로그인이 필요한 기능입니다.');
    }

    final folderPath = 'missions/${mission.id}/$userId';
    final fileName =
        'participation_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$folderPath/$fileName';

    await _client.storage
        .from(bucket.participation)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return (
      bucket: bucket.participation,
      folderPath: folderPath,
      fileName: fileName,
    );
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

  /// Fetches the count of mission participations submitted by the current user today.
  Future<int> getTodayParticipationCount() async {
    final userId = UserAuthService.instance.currentUser?.id;
    if (userId == null) {
      return 0;
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<dynamic> response = await _client
        .from(_participationTable.tableName)
        .select()
        .eq(MissionParticipationRow.participatedByField, userId)
        .gte(
          MissionParticipationRow.createdAtField,
          startOfDay.toIso8601String(),
        )
        .lt(MissionParticipationRow.createdAtField, endOfDay.toIso8601String());

    return response.length;
  }
}
