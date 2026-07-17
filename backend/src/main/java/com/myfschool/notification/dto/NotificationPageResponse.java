package com.myfschool.notification.dto;

import java.util.List;

public record NotificationPageResponse(
        List<NotificationItemResponse> items,
        int page,
        int size,
        long totalElements,
        int totalPages,
        long unreadCount
) {
    public NotificationPageResponse {
        items = List.copyOf(items);
    }
}
