import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    required this.eventId,
    this.useScaffold = true,
    this.onBack,
    super.key,
  });

  final String eventId;
  final bool useScaffold;
  final VoidCallback? onBack;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventRow? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvent();
  }

  Future<void> _fetchEvent() async {
    try {
      final response = await Supabase.instance.client
          .from(EventTable().tableName)
          .select()
          .eq(EventRow.idField, widget.eventId)
          .single();
      setState(() {
        _event = EventRow.fromJson(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      final body = const Center(child: CircularProgressIndicator());
      return widget.useScaffold
          ? Scaffold(
              appBar: AppBar(title: const Text('Event')),
              body: body,
            )
          : body;
    }

    if (_event == null) {
      final body = const Center(child: Text('Event not found'));
      return widget.useScaffold
          ? Scaffold(
              appBar: AppBar(title: const Text('Event')),
              body: body,
            )
          : body;
    }

    final event = _event!;
    final imageUrl = event.imageBucket != null && event.imageFileName != null
        ? getImageLink(
            event.imageBucket!,
            event.imageFileName!,
            folderPath: event.imageFolderPath,
          )
        : null;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.useScaffold && widget.onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to events'),
              ),
            ),
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(child: Icon(Icons.event)),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            event.title ?? 'No Title',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          if (event.startDate != null || event.endDate != null)
            Text(
              '${event.startDate ?? ''} - ${event.endDate ?? ''}',
              style: theme.textTheme.bodyLarge,
            ),
          if (event.startTime != null || event.endTime != null)
            Text(
              '${event.startTime ?? ''} - ${event.endTime ?? ''}',
              style: theme.textTheme.bodyLarge,
            ),
          const SizedBox(height: 16),
          if (event.content != null)
            Text(
              event.content!,
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );

    return widget.useScaffold
        ? Scaffold(
            appBar: AppBar(
              title: Text(event.title ?? 'Event'),
            ),
            body: body,
          )
        : body;
  }
}
