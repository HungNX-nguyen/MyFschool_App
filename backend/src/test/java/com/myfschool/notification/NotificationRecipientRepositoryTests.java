package com.myfschool.notification;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class NotificationRecipientRepositoryTests {

    @Autowired
    private NotificationRecipientRepository repository;

    @Autowired
    private EntityManager entityManager;

    @BeforeEach
    void setUp() {
        executeUpdate("""
                insert into account
                    (id, username, password_hash, status, created_at, updated_at)
                values
                    (10, 'recipient-10', 'hash', 'ACTIVE', current_timestamp, current_timestamp),
                    (11, 'recipient-11', 'hash', 'ACTIVE', current_timestamp, current_timestamp)
                """);
        executeUpdate("""
                insert into notification
                    (id, title, content, type, related_entity_type,
                     related_entity_id, created_at)
                values
                    (101, 'Thông báo cũ', 'Nội dung cũ', 'ANNOUNCEMENT',
                     'CLASS', 30, '2026-07-17 08:00:00'),
                    (102, 'Sự kiện mới', 'Nội dung mới', 'EVENT',
                     'SCHOOL_EVENT', 50, '2026-07-17 09:00:00'),
                    (103, 'Thông báo tài khoản khác', 'Không được trả về', 'SYSTEM',
                     null, null, '2026-07-17 10:00:00')
                """);
        executeUpdate("""
                insert into notification_recipient
                    (id, notification_id, account_id, is_read, read_at,
                     delivery_status, created_at)
                values
                    (201, 101, 10, true, '2026-07-17 08:30:00',
                     'PENDING', '2026-07-17 08:00:00'),
                    (202, 102, 10, false, null,
                     'PENDING', '2026-07-17 09:00:00'),
                    (203, 103, 11, false, null,
                     'PENDING', '2026-07-17 10:00:00')
                """);
        entityManager.clear();
    }

    @Test
    void returnsOnlyCurrentAccountNotificationsNewestFirst() {
        var result = repository.findForAccount(
                10L,
                null,
                PageRequest.of(0, 20)
        );

        assertThat(result.getTotalElements()).isEqualTo(2);
        assertThat(result.getContent())
                .extracting(recipient -> recipient.getNotification().getId())
                .containsExactly(102L, 101L);
    }

    @Test
    void filtersReadStateAndCountsUnreadForCurrentAccount() {
        var unread = repository.findForAccount(
                10L,
                false,
                PageRequest.of(0, 20)
        );

        assertThat(unread.getContent())
                .extracting(recipient -> recipient.getNotification().getId())
                .containsExactly(102L);
        assertThat(repository.countByAccount_IdAndReadFalse(10L)).isEqualTo(1);
        assertThat(repository.countByAccount_IdAndReadFalse(11L)).isEqualTo(1);
    }

    @Test
    void findsDetailOnlyForRecipientAccount() {
        assertThat(repository.findAccessibleNotification(10L, 102L))
                .isPresent()
                .get()
                .extracting(recipient -> recipient.getNotification().getId())
                .isEqualTo(102L);
        assertThat(repository.findAccessibleNotification(10L, 103L)).isEmpty();
        assertThat(repository.findAccessibleNotification(11L, 102L)).isEmpty();
    }

    @Test
    void marksAllUnreadOnlyForSelectedAccount() {
        var updated = repository.markAllUnreadAsRead(
                10L,
                LocalDateTime.of(2026, 7, 17, 11, 0)
        );

        assertThat(updated).isEqualTo(1);
        assertThat(repository.countByAccount_IdAndReadFalse(10L)).isZero();
        assertThat(repository.countByAccount_IdAndReadFalse(11L)).isEqualTo(1);
        assertThat(repository.findAccessibleNotification(10L, 102L))
                .isPresent()
                .get()
                .satisfies(recipient -> {
                    assertThat(recipient.isRead()).isTrue();
                    assertThat(recipient.getReadAt())
                            .isEqualTo(LocalDateTime.of(2026, 7, 17, 11, 0));
                });
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
