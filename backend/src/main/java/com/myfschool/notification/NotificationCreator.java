package com.myfschool.notification;

import com.myfschool.account.Account;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class NotificationCreator {

    private final NotificationRepository notificationRepository;

    public NotificationCreator(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    public Notification createForEntity(
            String title,
            String content,
            NotificationType type,
            String relatedEntityType,
            Long relatedEntityId,
            Account createdByAccount,
            List<Account> recipientAccounts
    ) {
        if (recipientAccounts.isEmpty()) {
            throw new BusinessException(
                    ErrorCode.BUSINESS_RULE_VIOLATION,
                    HttpStatus.CONFLICT,
                    "Không có tài khoản nhận thông báo phù hợp"
            );
        }

        var notification = new Notification(
                title,
                content,
                type,
                null,
                relatedEntityType,
                relatedEntityId,
                createdByAccount
        );
        recipientAccounts.forEach(notification::addRecipient);
        return notificationRepository.save(notification);
    }
}
