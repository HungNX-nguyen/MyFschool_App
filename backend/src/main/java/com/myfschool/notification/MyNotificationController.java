package com.myfschool.notification;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.notification.dto.MarkAllNotificationsReadResponse;
import com.myfschool.notification.dto.NotificationDetailResponse;
import com.myfschool.notification.dto.NotificationPageResponse;
import com.myfschool.notification.dto.UnreadNotificationCountResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications/me")
public class MyNotificationController {

    private final MyNotificationService myNotificationService;

    public MyNotificationController(MyNotificationService myNotificationService) {
        this.myNotificationService = myNotificationService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<NotificationPageResponse>> getMyNotifications(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @RequestParam(required = false) Boolean isRead,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                myNotificationService.getMyNotifications(
                        principal.accountId(),
                        isRead,
                        page,
                        size
                )
        ));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<UnreadNotificationCountResponse>> getMyUnreadCount(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                myNotificationService.getMyUnreadCount(principal.accountId())
        ));
    }

    @GetMapping("/{notificationId}")
    public ResponseEntity<ApiResponse<NotificationDetailResponse>> getMyNotification(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long notificationId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                myNotificationService.getMyNotification(
                        principal.accountId(),
                        notificationId
                )
        ));
    }

    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<NotificationDetailResponse>> markMyNotificationRead(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long notificationId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                myNotificationService.markMyNotificationRead(
                        principal.accountId(),
                        notificationId
                ),
                "Đã đánh dấu thông báo là đã đọc"
        ));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<ApiResponse<MarkAllNotificationsReadResponse>> markAllRead(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                myNotificationService.markAllMyNotificationsRead(principal.accountId()),
                "Đã đánh dấu tất cả thông báo là đã đọc"
        ));
    }
}
