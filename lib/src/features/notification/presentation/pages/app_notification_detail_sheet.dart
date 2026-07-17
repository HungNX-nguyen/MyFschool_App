import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/app_notification.dart';
import '../utils/app_notification_formatters.dart';

class AppNotificationDetailSheet extends StatelessWidget {
  const AppNotificationDetailSheet({required this.detail, super.key});

  final AppNotificationDetail detail;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 2, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.3,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatAppNotificationTime(detail.createdAt),
                    style: const TextStyle(color: Color(0xFF666666)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Nội dung',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              SelectableText(
                detail.content,
                style: const TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
