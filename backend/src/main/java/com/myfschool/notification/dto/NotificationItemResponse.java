package com.myfschool.notification.dto;

import com.myfschool.notification.NotificationType;

import java.time.LocalDateTime;

public record NotificationItemResponse(
        Long notificationId,
        String title,
        String contentPreview,
        NotificationType type,
        LocalDateTime createdAt,
        boolean isRead,
        LocalDateTime readAt,
        String relatedEntityType,
        Long relatedEntityId
) {
}
