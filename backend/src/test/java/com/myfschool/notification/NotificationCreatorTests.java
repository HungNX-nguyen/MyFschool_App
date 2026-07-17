package com.myfschool.notification;

import com.myfschool.account.Account;
import com.myfschool.common.exception.BusinessException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationCreatorTests {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationCreator notificationCreator;

    @Test
    void createsEntityNotificationWithAllRecipients() {
        var creatorAccount = mock(Account.class);
        var firstRecipient = mock(Account.class);
        var secondRecipient = mock(Account.class);
        when(notificationRepository.save(any(Notification.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        var result = notificationCreator.createForEntity(
                "Sự kiện lớp",
                "Nội dung sự kiện",
                NotificationType.EVENT,
                "SCHOOL_EVENT",
                50L,
                creatorAccount,
                List.of(firstRecipient, secondRecipient)
        );

        var captor = ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository).save(captor.capture());
        var notification = captor.getValue();
        assertThat(result).isSameAs(notification);
        assertThat(notification.getType()).isEqualTo(NotificationType.EVENT);
        assertThat(notification.getRelatedEntityType()).isEqualTo("SCHOOL_EVENT");
        assertThat(notification.getRelatedEntityId()).isEqualTo(50L);
        assertThat(notification.getCreatedByAccount()).isSameAs(creatorAccount);
        assertThat(notification.getRecipients())
                .extracting(NotificationRecipient::getAccount)
                .containsExactlyInAnyOrder(firstRecipient, secondRecipient);
    }

    @Test
    void rejectsNotificationWithoutRecipients() {
        assertThatThrownBy(() -> notificationCreator.createForEntity(
                "Thông báo",
                "Nội dung",
                NotificationType.ANNOUNCEMENT,
                "CLASS",
                30L,
                mock(Account.class),
                List.of()
        )).isInstanceOf(BusinessException.class);

        verify(notificationRepository, never()).save(any());
    }
}
