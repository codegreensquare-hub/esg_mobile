import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/database/mission_participation.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MissionDetailDialog extends StatefulWidget {
  final MissionRow mission;

  const MissionDetailDialog({
    super.key,
    required this.mission,
  });

  @override
  State<MissionDetailDialog> createState() => _MissionDetailDialogState();
}

class _MissionDetailDialogState extends State<MissionDetailDialog> {
  List<MissionPhotoTaskRow> _taskPhotos = [];
  List<MissionPhotoNotAllowedRow> _notAllowedPhotos = [];
  bool _isLoadingPhotos = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch task photos for this mission
      final taskPhotosResponse = await supabase
          .from('mission_photo_task')
          .select()
          .eq('mission', widget.mission.id)
          .order('order');

      // Fetch not allowed photos for this mission
      final notAllowedPhotosResponse = await supabase
          .from('mission_photo_not_allowed')
          .select()
          .eq('mission', widget.mission.id)
          .order('order');

      setState(() {
        _taskPhotos = (taskPhotosResponse as List)
            .map((json) => MissionPhotoTaskRow.fromJson(json))
            .toList();
        _notAllowedPhotos = (notAllowedPhotosResponse as List)
            .map((json) => MissionPhotoNotAllowedRow.fromJson(json))
            .toList();
        _isLoadingPhotos = false;
      });
    } catch (e) {
      debugPrint('Error fetching mission photos: $e');
      setState(() {
        _isLoadingPhotos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        widget.mission.thumbnailBucket != null &&
            widget.mission.thumbnailFilename != null
        ? getImageLink(
            widget.mission.thumbnailBucket!,
            widget.mission.thumbnailFilename!,
            folderPath: widget.mission.thumbnailFolderPath,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'mission_title_${widget.mission.id}',
          child: Text(
            widget.mission.title ?? 'No Title',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Hero - square, max 200x200
              if (imageUrl != null)
                Hero(
                  tag: 'mission_image_${widget.mission.id}',
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 48),
                    ),
                  ),
                ),
              // Title with Hero
              const SizedBox(height: 16),
              // Description with Hero
              Hero(
                tag: 'mission_text_${widget.mission.id}',
                child: Text(
                  widget.mission.text ?? 'No Description',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),
              // Additional details
              if (widget.mission.taskExplanation != null) ...[
                Text(
                  'Explanation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.mission.taskExplanation!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ],
              if (widget.mission.awardPoints > 0) ...[
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.mission.awardPoints} Points',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              // 이렇게 해 주세요 Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '이렇게 해 주세요',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Text('👍'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '어떤 종류의 친환경 일상이든,\n서대문구임을 알 수 있는 랜드마크나 표지판,\n또는 영수증과 함께 친환경 일상 인증 사진을 찍어 주세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Grid of task photos
                    if (_isLoadingPhotos)
                      const Center(child: CircularProgressIndicator())
                    else if (_taskPhotos.isEmpty)
                      const SizedBox.shrink()
                    else
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: _taskPhotos.map((photo) {
                          final photoUrl = getImageLink(
                            photo.bucket,
                            photo.fileName,
                            folderPath: photo.folderPath,
                          );
                          return CachedNetworkImage(
                            imageUrl: photoUrl,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 이건 안 돼요 Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '이건 안 돼요',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Text('✋'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '친환경 일상을 인증하는 사진이더라도, 서대문구임을 알 수 없는 사진은 인증이 어려워요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Grid of not allowed photos
                    if (_isLoadingPhotos)
                      const Center(child: CircularProgressIndicator())
                    else if (_notAllowedPhotos.isEmpty)
                      const SizedBox.shrink()
                    else
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: _notAllowedPhotos.map((photo) {
                          final photoUrl = getImageLink(
                            photo.bucket,
                            photo.fileName,
                            folderPath: photo.folderPath,
                          );
                          return CachedNetworkImage(
                            imageUrl: photoUrl,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Participate Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => MissionParticipationService.instance
                      .startParticipationFlow(
                        context: context,
                        mission: widget.mission,
                      ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.mission.participationButtonText ??
                        'Participate in Mission',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 유의사항 Section
              Text(
                '유의사항',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNoteItem('미션 참여는 하루에 최대 10회까지 가능합니다.'),
                  _buildNoteItem('위의 인증 기준에 따라 주셔야 심사가 통과됩니다.'),
                  _buildNoteItem('미션 참여 방식은 변경될 수 있습니다.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
