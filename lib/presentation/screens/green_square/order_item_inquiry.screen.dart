import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class OrderItemInquiryScreen extends StatefulWidget {
  const OrderItemInquiryScreen({
    super.key,
    required this.orderItem,
    required this.product,
  });

  final OrderItemRow orderItem;
  final ProductRow? product;

  @override
  State<OrderItemInquiryScreen> createState() => _OrderItemInquiryScreenState();
}

class _OrderItemInquiryScreenState extends State<OrderItemInquiryScreen>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <OrderItemInquiryMessageRow>[];
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isRefreshing = false;
  DateTime? _lastMessageTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopPolling();
    } else if (state == AppLifecycleState.resumed) {
      _startPolling();
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await Supabase.instance.client
          .from(OrderItemInquiryMessageTable().tableName)
          .select()
          .eq(OrderItemInquiryMessageRow.orderItemField, widget.orderItem.id)
          .order(OrderItemInquiryMessageRow.createdAtField, ascending: true);

      final messages = response
          .whereType<Map<String, dynamic>>()
          .map(OrderItemInquiryMessageRow.fromJson)
          .toList();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
          _isLoading = false;
          _lastMessageTime = messages.isNotEmpty
              ? messages.last.createdAt
              : DateTime.now();
        });
        _scrollToBottom();
        _startPolling();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startPolling() {
    _stopPolling(); // Ensure no duplicate timers
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _pollNewMessages();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _pollNewMessages() async {
    if (!mounted || _lastMessageTime == null) return;

    try {
      final response = await Supabase.instance.client
          .from(OrderItemInquiryMessageTable().tableName)
          .select()
          .eq(OrderItemInquiryMessageRow.orderItemField, widget.orderItem.id)
          .gt(
            OrderItemInquiryMessageRow.createdAtField,
            _lastMessageTime!.toUtc().toIso8601String(),
          )
          .order(OrderItemInquiryMessageRow.createdAtField, ascending: true);

      final newMessages = response
          .whereType<Map<String, dynamic>>()
          .map(OrderItemInquiryMessageRow.fromJson)
          .toList();

      if (newMessages.isNotEmpty && mounted) {
        setState(() {
          _messages.addAll(newMessages);
          _lastMessageTime = newMessages.last.createdAt;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error polling messages: $e');
      // Don't show error to user for polling failures
    }
  }

  Future<void> _refreshMessages() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final response = await Supabase.instance.client
          .from(OrderItemInquiryMessageTable().tableName)
          .select()
          .eq(OrderItemInquiryMessageRow.orderItemField, widget.orderItem.id)
          .order(OrderItemInquiryMessageRow.createdAtField, ascending: true);

      final messages = response
          .whereType<Map<String, dynamic>>()
          .map(OrderItemInquiryMessageRow.fromJson)
          .toList();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
          _lastMessageTime = messages.isNotEmpty
              ? messages.last.createdAt
              : DateTime.now();
          _isRefreshing = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error refreshing messages: $e');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // For reverse ListView, 0.0 is the bottom (newest messages)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await Supabase.instance.client
          .from(OrderItemInquiryMessageTable().tableName)
          .insert({
            OrderItemInquiryMessageRow.orderItemField: widget.orderItem.id,
            OrderItemInquiryMessageRow.textField: text,
            OrderItemInquiryMessageRow.createdByField: currentUser.id,
          });

      _messageController.clear();

      // Refresh messages to include the newly sent message
      await _refreshMessages();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지 전송 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final product = widget.product;
    final productTitle = (product?.title ?? product?.name)?.trim() ?? '';
    final titleText = productTitle.isEmpty ? '상품 정보 없음' : productTitle;
    final quantity = widget.orderItem.quantity ?? 0;
    final quantityText = quantity % 1 == 0
        ? '${quantity.toInt()}'
        : '$quantity';

    final imageUrl =
        product?.mainImageBucket != null && product?.mainImageFileName != null
        ? getImageLink(
            product!.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    final bottomSafetyPadding = MediaQuery.paddingOf(context).bottom;
    final bottomPadding = bottomSafetyPadding > 0 ? bottomSafetyPadding : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 문의'),
      ),
      body: Column(
        children: [
          // Order Item Info Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                          )
                        : Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_outlined,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '수량: $quantityText',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshMessages,
                    child: _messages.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: Center(
                                  child: Text(
                                    '메시지가 없습니다.\n첫 문의를 남겨보세요.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true, // Messages appear from bottom up
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  _messages[_messages.length -
                                      1 -
                                      index]; // Reverse index for correct chronological order
                              final isMyMessage =
                                  message.createdBy == currentUserId;
                              final text = message.text ?? '';
                              final time = message.createdAt
                                  .toLocal()
                                  .toString()
                                  .split(' ')[1]
                                  .substring(0, 5);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: isMyMessage
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (isMyMessage) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          time,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMyMessage
                                              ? cs.primaryContainer
                                              : cs.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          text,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: isMyMessage
                                                    ? cs.onPrimary
                                                    : cs.onSurface,
                                              ),
                                        ),
                                      ),
                                    ),
                                    if (!isMyMessage) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          time,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),

          // Input Section
          Container(
            padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _isSending ? null : _sendMessage,
                  backgroundColor: cs.primary,
                  child: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : Icon(Icons.send, color: cs.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
