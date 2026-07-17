package com.myfschool.notification.dto;

import com.myfschool.notification.NotificationType;

import java.time.LocalDateTime;

public record NotificationDetailResponse(
        Long notificationId,
        String title,
        String content,
        NotificationType type,
        LocalDateTime createdAt,
        boolean isRead,
        LocalDateTime readAt,
        String relatedEntityType,
        Long relatedEntityId,
        NotificationNavigationTargetResponse navigationTarget
) {
}
