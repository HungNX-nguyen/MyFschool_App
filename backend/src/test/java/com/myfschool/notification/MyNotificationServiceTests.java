package com.myfschool.notification;

import com.myfschool.common.exception.BusinessException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MyNotificationServiceTests {

    @Mock
    private NotificationRecipientRepository notificationRecipientRepository;

    @InjectMocks
    private MyNotificationService myNotificationService;

    @Test
    void returnsPagedNotificationsAndUnreadCountForCurrentAccount() {
        var createdAt = LocalDateTime.of(2026, 7, 17, 9, 30);
        var notification = mock(Notification.class);
        when(notification.getId()).thenReturn(101L);
        when(notification.getTitle()).thenReturn("Họp phụ huynh");
        when(notification.getContent()).thenReturn("  Nội dung\n  sự kiện lớp.  ");
        when(notification.getType()).thenReturn(NotificationType.EVENT);
        when(notification.getCreatedAt()).thenReturn(createdAt);
        when(notification.getRelatedEntityType()).thenReturn("SCHOOL_EVENT");
        when(notification.getRelatedEntityId()).thenReturn(55L);

        var recipient = mock(NotificationRecipient.class);
        when(recipient.getNotification()).thenReturn(notification);
        when(recipient.isRead()).thenReturn(false);
        when(recipient.getReadAt()).thenReturn(null);

        var pageable = PageRequest.of(0, 20);
        when(notificationRecipientRepository.findForAccount(10L, false, pageable))
                .thenReturn(new PageImpl<>(List.of(recipient), pageable, 1));
        when(notificationRecipientRepository.countByAccount_IdAndReadFalse(10L))
                .thenReturn(3L);

        var result = myNotificationService.getMyNotifications(
                10L,
                false,
                0,
                20
        );

        assertThat(result.page()).isZero();
        assertThat(result.size()).isEqualTo(20);
        assertThat(result.totalElements()).isEqualTo(1);
        assertThat(result.totalPages()).isEqualTo(1);
        assertThat(result.unreadCount()).isEqualTo(3);
        assertThat(result.items()).singleElement().satisfies(item -> {
            assertThat(item.notificationId()).isEqualTo(101L);
            assertThat(item.title()).isEqualTo("Họp phụ huynh");
            assertThat(item.contentPreview()).isEqualTo("Nội dung sự kiện lớp.");
            assertThat(item.type()).isEqualTo(NotificationType.EVENT);
            assertThat(item.createdAt()).isEqualTo(createdAt);
            assertThat(item.isRead()).isFalse();
            assertThat(item.relatedEntityType()).isEqualTo("SCHOOL_EVENT");
            assertThat(item.relatedEntityId()).isEqualTo(55L);
        });
    }

    @Test
    void returnsUnreadCountWithoutLoadingNotificationPage() {
        when(notificationRecipientRepository.countByAccount_IdAndReadFalse(10L))
                .thenReturn(4L);

        var result = myNotificationService.getMyUnreadCount(10L);

        assertThat(result.unreadCount()).isEqualTo(4);
        verify(notificationRecipientRepository)
                .countByAccount_IdAndReadFalse(10L);
    }

    @Test
    void returnsOnlyAccessibleNotificationDetailWithNavigationTarget() {
        var notification = detailNotification();
        var recipient = mock(NotificationRecipient.class);
        when(recipient.getNotification()).thenReturn(notification);
        when(recipient.isRead()).thenReturn(false);
        when(notificationRecipientRepository.findAccessibleNotification(10L, 101L))
                .thenReturn(Optional.of(recipient));

        var result = myNotificationService.getMyNotification(10L, 101L);

        assertThat(result.notificationId()).isEqualTo(101L);
        assertThat(result.content()).isEqualTo("Nội dung sự kiện đầy đủ");
        assertThat(result.isRead()).isFalse();
        assertThat(result.navigationTarget().type()).isEqualTo("SCHOOL_EVENT");
        assertThat(result.navigationTarget().id()).isEqualTo(55L);
    }

    @Test
    void marksSingleNotificationReadAndHidesForeignNotificationAsNotFound() {
        var notification = detailNotification();
        var readAt = LocalDateTime.of(2026, 7, 17, 10, 0);
        var recipient = mock(NotificationRecipient.class);
        when(recipient.getNotification()).thenReturn(notification);
        when(recipient.isRead()).thenReturn(true);
        when(recipient.getReadAt()).thenReturn(readAt);
        when(notificationRecipientRepository.findAccessibleNotification(10L, 101L))
                .thenReturn(Optional.of(recipient));
        when(notificationRecipientRepository.findAccessibleNotification(10L, 999L))
                .thenReturn(Optional.empty());

        var result = myNotificationService.markMyNotificationRead(10L, 101L);

        verify(recipient).markRead(org.mockito.ArgumentMatchers.any(LocalDateTime.class));
        assertThat(result.isRead()).isTrue();
        assertThat(result.readAt()).isEqualTo(readAt);

        assertThatThrownBy(() -> myNotificationService.getMyNotification(10L, 999L))
                .isInstanceOf(BusinessException.class)
                .hasMessage("Thông báo không tồn tại");
    }

    @Test
    void preservesOriginalReadTimeWhenMarkReadIsRepeated() {
        var recipient = new NotificationRecipient(
                mock(Notification.class),
                mock(com.myfschool.account.Account.class)
        );
        var firstReadAt = LocalDateTime.of(2026, 7, 17, 10, 0);

        recipient.markRead(firstReadAt);
        recipient.markRead(firstReadAt.plusHours(1));

        assertThat(recipient.isRead()).isTrue();
        assertThat(recipient.getReadAt()).isEqualTo(firstReadAt);
    }

    @Test
    void marksAllUnreadNotificationsForCurrentAccount() {
        when(notificationRecipientRepository.markAllUnreadAsRead(
                org.mockito.ArgumentMatchers.eq(10L),
                org.mockito.ArgumentMatchers.any(LocalDateTime.class)
        )).thenReturn(2);
        when(notificationRecipientRepository.countByAccount_IdAndReadFalse(10L))
                .thenReturn(0L);

        var result = myNotificationService.markAllMyNotificationsRead(10L);

        assertThat(result.updatedCount()).isEqualTo(2);
        assertThat(result.unreadCount()).isZero();
    }

    @Test
    void rejectsInvalidPaginationBeforeQueryingDatabase() {
        assertThatThrownBy(() -> myNotificationService.getMyNotifications(
                10L,
                null,
                -1,
                20
        )).isInstanceOf(BusinessException.class)
                .hasMessage("page phải lớn hơn hoặc bằng 0");

        assertThatThrownBy(() -> myNotificationService.getMyNotifications(
                10L,
                null,
                0,
                101
        )).isInstanceOf(BusinessException.class)
                .hasMessage("size phải nằm trong khoảng từ 1 đến 100");

        verifyNoInteractions(notificationRecipientRepository);
    }

    private Notification detailNotification() {
        var notification = mock(Notification.class);
        when(notification.getId()).thenReturn(101L);
        when(notification.getTitle()).thenReturn("Họp phụ huynh");
        when(notification.getContent()).thenReturn("Nội dung sự kiện đầy đủ");
        when(notification.getType()).thenReturn(NotificationType.EVENT);
        when(notification.getCreatedAt())
                .thenReturn(LocalDateTime.of(2026, 7, 17, 9, 30));
        when(notification.getRelatedEntityType()).thenReturn("SCHOOL_EVENT");
        when(notification.getRelatedEntityId()).thenReturn(55L);
        return notification;
    }
}
