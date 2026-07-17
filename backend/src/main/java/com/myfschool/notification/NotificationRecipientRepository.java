package com.myfschool.notification;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface NotificationRecipientRepository extends JpaRepository<NotificationRecipient, Long> {

    @Query(
            value = """
                    select recipient
                    from NotificationRecipient recipient
                    join fetch recipient.notification notification
                    where recipient.account.id = :accountId
                      and (:isRead is null or recipient.read = :isRead)
                    order by notification.createdAt desc, notification.id desc
                    """,
            countQuery = """
                    select count(recipient)
                    from NotificationRecipient recipient
                    where recipient.account.id = :accountId
                      and (:isRead is null or recipient.read = :isRead)
                    """
    )
    Page<NotificationRecipient> findForAccount(
            @Param("accountId") Long accountId,
            @Param("isRead") Boolean isRead,
            Pageable pageable
    );

    long countByAccount_IdAndReadFalse(Long accountId);

    @Query("""
            select recipient
            from NotificationRecipient recipient
            join fetch recipient.notification notification
            where recipient.account.id = :accountId
              and notification.id = :notificationId
            """)
    Optional<NotificationRecipient> findAccessibleNotification(
            @Param("accountId") Long accountId,
            @Param("notificationId") Long notificationId
    );

    @Query("""
            select count(recipient) > 0
            from NotificationRecipient recipient
            join recipient.notification notification
            where recipient.account.id = :accountId
              and notification.type = com.myfschool.notification.NotificationType.EVENT
              and notification.relatedEntityType = 'SCHOOL_EVENT'
              and notification.relatedEntityId = :eventId
            """)
    boolean existsSchoolEventRecipient(
            @Param("accountId") Long accountId,
            @Param("eventId") Long eventId
    );

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            update NotificationRecipient recipient
            set recipient.read = true,
                recipient.readAt = :readAt
            where recipient.account.id = :accountId
              and recipient.read = false
            """)
    int markAllUnreadAsRead(
            @Param("accountId") Long accountId,
            @Param("readAt") LocalDateTime readAt
    );
}
