import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/code_green/event_detail.screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventTab extends StatefulWidget {
  static const tab = 'event';
  const EventTab({super.key});

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
  List<EventRow> _events = [];
  bool _loading = true;
  String? _selectedEventId;

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.replaceAll('-', '.');
    }
    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  String _formatTime(String value) {
    final parts = value.split(':').map((e) => int.tryParse(e)).toList();
    final hour = parts.isNotEmpty ? parts.first : null;
    if (hour == null) {
      return value;
    }
    final minute = parts.length > 1 && parts[1] != null ? parts[1]! : 0;
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteText$suffix';
  }

  String _buildDateRange(EventRow event) {
    final startDate = event.startDate;
    final endDate = event.endDate;
    if (startDate == null || endDate == null) {
      return startDate != null ? _formatDate(startDate) : '';
    }

    final startTime = event.startTime;
    final endTime = event.endTime;
    final startText = startTime != null && startTime.trim().isNotEmpty
        ? '${_formatDate(startDate)}(${_formatTime(startTime)})'
        : _formatDate(startDate);
    final endText = endTime != null && endTime.trim().isNotEmpty
        ? '${_formatDate(endDate)}(${_formatTime(endTime)})'
        : _formatDate(endDate);
    return '$startText~$endText';
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await Supabase.instance.client
          .from(EventTable().tableName)
          .select()
          .order(EventRow.createdAtField, ascending: false);
      final events = (response as List)
          .map((e) => EventRow.fromJson(e))
          .toList();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_selectedEventId != null) {
      return EventDetailScreen(
        eventId: _selectedEventId!,
        useScaffold: false,
        onBack: () => setState(() => _selectedEventId = null),
      );
    }
    if (_loading) {
      return Container(
        color: theme.colorScheme.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_events.isEmpty) {
      return Container(
        color: theme.colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                'No Events Available',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '새로운 이벤트가 곧 추가됩니다.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final imageUrl =
                  event.imageBucket != null && event.imageFileName != null
                  ? getImageLink(
                      event.imageBucket!,
                      event.imageFileName!,
                      folderPath: event.imageFolderPath,
                    )
                  : null;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _selectedEventId = event.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.event,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.event,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title ?? 'No Title',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (event.startDate != null)
                              Text(
                                _buildDateRange(event),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
