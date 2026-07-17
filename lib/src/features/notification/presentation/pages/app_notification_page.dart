import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_shared_widgets.dart';
import '../../../school_event/presentation/pages/school_event_page.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/app_notification_controller.dart';
import '../utils/app_notification_formatters.dart';
import 'app_notification_detail_sheet.dart';

class AppNotificationPage extends StatefulWidget {
  const AppNotificationPage({
    required this.controller,
    required this.onAccountTap,
    super.key,
  });

  final AppNotificationController controller;
  final VoidCallback onAccountTap;

  @override
  State<AppNotificationPage> createState() => _AppNotificationPageState();
}

class _AppNotificationPageState extends State<AppNotificationPage> {
  final _scrollController = ScrollController();
  bool _isPresentingError = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadInitial();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppNotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadInitial();
      }
    });
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 240) {
      widget.controller.loadMore();
    }
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    final error = widget.controller.actionErrorMessage;
    if (error == null || _isPresentingError) {
      return;
    }
    _isPresentingError = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      widget.controller.clearActionError();
      _isPresentingError = false;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textColor,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Quay lại',
          iconSize: 29,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (widget.controller.hasUnread)
            TextButton(
              onPressed: widget.controller.isMarkingAllRead
                  ? null
                  : widget.controller.markAllRead,
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildContent(),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: 2,
        notificationController: widget.controller,
        onHomeTap: () => Navigator.of(context).maybePop(),
        onAccountTap: widget.onAccountTap,
      ),
    );
  }

  Widget _buildContent() {
    final controller = widget.controller;
    if ((controller.status == AppNotificationPageStatus.idle ||
            controller.status == AppNotificationPageStatus.loading) &&
        controller.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }
    if (controller.status == AppNotificationPageStatus.error &&
        controller.items.isEmpty) {
      return _NotificationErrorState(
        message: controller.errorMessage ?? 'Không thể tải thông báo.',
        onRetry: controller.loadInitial,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: controller.loadInitial,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        itemCount: controller.items.isEmpty
            ? 1
            : controller.items.length + (controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (controller.items.isEmpty) {
            return const _NotificationEmptyState();
          }
          if (index == controller.items.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            );
          }
          final item = controller.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NotificationCard(
              item: item,
              isOpening: controller.openingNotificationId == item.id,
              onTap: () => _openNotification(item),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openNotification(AppNotificationItem item) async {
    final result = await widget.controller.openNotification(item.id);
    if (!mounted || result == null) {
      return;
    }
    final event = result.schoolEvent;
    if (event != null) {
      await showSchoolEventDetails(context, event);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => AppNotificationDetailSheet(detail: result.detail),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.isOpening,
    required this.onTap,
  });

  final AppNotificationItem item;
  final bool isOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final event = item.type == AppNotificationType.event;
    return Material(
      key: ValueKey('notification-item-${item.id}'),
      color: item.isRead ? Colors.white : const Color(0xFFFFF2ED),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isOpening ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFFE4E4E4)
                  : const Color(0xFFFFB49B),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8DF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  event ? Icons.event_rounded : Icons.campaign_rounded,
                  color: AppTheme.primaryColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: item.isRead
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor: Color(0xFFE6001A),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.contentPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        _TypeChip(event: event),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatAppNotificationTime(item.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isOpening) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.event});

  final bool event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: event ? const Color(0xFFE7F4FF) : const Color(0xFFFFE7DE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        event ? 'Sự kiện' : 'Thông báo',
        style: TextStyle(
          color: event ? const Color(0xFF1769AA) : AppTheme.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 170),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 68,
            color: Color(0xFFAAAAAA),
          ),
          SizedBox(height: 14),
          Text(
            'Bạn chưa có thông báo nào.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NotificationErrorState extends StatelessWidget {
  const _NotificationErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFAAAAAA),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
