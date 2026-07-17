package com.myfschool.notification.dto;

import java.time.LocalDateTime;

public record ClassNotificationResponse(
        Long notificationId,
        int recipientCount,
        LocalDateTime createdAt
) {
}
