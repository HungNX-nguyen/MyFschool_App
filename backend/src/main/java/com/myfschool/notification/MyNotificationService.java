package com.myfschool.notification;

import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.notification.dto.MarkAllNotificationsReadResponse;
import com.myfschool.notification.dto.NotificationDetailResponse;
import com.myfschool.notification.dto.NotificationItemResponse;
import com.myfschool.notification.dto.NotificationNavigationTargetResponse;
import com.myfschool.notification.dto.NotificationPageResponse;
import com.myfschool.notification.dto.UnreadNotificationCountResponse;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class MyNotificationService {

    private static final int MAX_PAGE_SIZE = 100;
    private static final int CONTENT_PREVIEW_MAX_LENGTH = 160;

    private final NotificationRecipientRepository notificationRecipientRepository;

    public MyNotificationService(
            NotificationRecipientRepository notificationRecipientRepository
    ) {
        this.notificationRecipientRepository = notificationRecipientRepository;
    }

    @Transactional(readOnly = true)
    public NotificationPageResponse getMyNotifications(
            Long accountId,
            Boolean isRead,
            int page,
            int size
    ) {
        validatePagination(page, size);
        var recipientPage = notificationRecipientRepository.findForAccount(
                accountId,
                isRead,
                PageRequest.of(page, size)
        );
        var items = recipientPage.getContent()
                .stream()
                .map(this::toItemResponse)
                .toList();
        var unreadCount = notificationRecipientRepository
                .countByAccount_IdAndReadFalse(accountId);

        return new NotificationPageResponse(
                items,
                recipientPage.getNumber(),
                recipientPage.getSize(),
                recipientPage.getTotalElements(),
                recipientPage.getTotalPages(),
                unreadCount
        );
    }

    @Transactional(readOnly = true)
    public UnreadNotificationCountResponse getMyUnreadCount(Long accountId) {
        return new UnreadNotificationCountResponse(
                notificationRecipientRepository.countByAccount_IdAndReadFalse(accountId)
        );
    }

    @Transactional(readOnly = true)
    public NotificationDetailResponse getMyNotification(
            Long accountId,
            Long notificationId
    ) {
        return toDetailResponse(findAccessibleNotification(accountId, notificationId));
    }

    @Transactional
    public NotificationDetailResponse markMyNotificationRead(
            Long accountId,
            Long notificationId
    ) {
        var recipient = findAccessibleNotification(accountId, notificationId);
        recipient.markRead(LocalDateTime.now());
        return toDetailResponse(recipient);
    }

    @Transactional
    public MarkAllNotificationsReadResponse markAllMyNotificationsRead(Long accountId) {
        var updatedCount = notificationRecipientRepository.markAllUnreadAsRead(
                accountId,
                LocalDateTime.now()
        );
        var unreadCount = notificationRecipientRepository
                .countByAccount_IdAndReadFalse(accountId);
        return new MarkAllNotificationsReadResponse(updatedCount, unreadCount);
    }

    private NotificationItemResponse toItemResponse(NotificationRecipient recipient) {
        var notification = recipient.getNotification();
        return new NotificationItemResponse(
                notification.getId(),
                notification.getTitle(),
                toContentPreview(notification.getContent()),
                notification.getType(),
                notification.getCreatedAt(),
                recipient.isRead(),
                recipient.getReadAt(),
                notification.getRelatedEntityType(),
                notification.getRelatedEntityId()
        );
    }

    private NotificationDetailResponse toDetailResponse(NotificationRecipient recipient) {
        var notification = recipient.getNotification();
        return new NotificationDetailResponse(
                notification.getId(),
                notification.getTitle(),
                notification.getContent(),
                notification.getType(),
                notification.getCreatedAt(),
                recipient.isRead(),
                recipient.getReadAt(),
                notification.getRelatedEntityType(),
                notification.getRelatedEntityId(),
                toNavigationTarget(notification)
        );
    }

    private NotificationNavigationTargetResponse toNavigationTarget(
            Notification notification
    ) {
        if (notification.getRelatedEntityType() == null
                || notification.getRelatedEntityId() == null) {
            return null;
        }
        return new NotificationNavigationTargetResponse(
                notification.getRelatedEntityType(),
                notification.getRelatedEntityId()
        );
    }

    private NotificationRecipient findAccessibleNotification(
            Long accountId,
            Long notificationId
    ) {
        return notificationRecipientRepository
                .findAccessibleNotification(accountId, notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Thông báo"));
    }

    private String toContentPreview(String content) {
        var normalized = content.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= CONTENT_PREVIEW_MAX_LENGTH) {
            return normalized;
        }
        return normalized.substring(0, CONTENT_PREVIEW_MAX_LENGTH - 3).trim() + "...";
    }

    private void validatePagination(int page, int size) {
        if (page < 0) {
            throw validationError("page phải lớn hơn hoặc bằng 0");
        }
        if (size < 1 || size > MAX_PAGE_SIZE) {
            throw validationError("size phải nằm trong khoảng từ 1 đến 100");
        }
    }

    private BusinessException validationError(String message) {
        return new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                HttpStatus.BAD_REQUEST,
                message
        );
    }
}
