package com.myfschool.notification.dto;

public record MarkAllNotificationsReadResponse(
        int updatedCount,
        long unreadCount
) {
}
