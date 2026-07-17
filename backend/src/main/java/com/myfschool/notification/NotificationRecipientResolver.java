package com.myfschool.notification;

import com.myfschool.account.Account;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Component
public class NotificationRecipientResolver {

    private final NotificationAudienceRepository audienceRepository;

    public NotificationRecipientResolver(
            NotificationAudienceRepository audienceRepository
    ) {
        this.audienceRepository = audienceRepository;
    }

    public List<Account> resolve(
            Long classId,
            Long academicYearId,
            NotificationRecipientType recipientType
    ) {
        Objects.requireNonNull(classId, "classId must not be null");
        Objects.requireNonNull(academicYearId, "academicYearId must not be null");
        Objects.requireNonNull(recipientType, "recipientType must not be null");

        Map<Long, Account> recipientsByAccountId = new LinkedHashMap<>();

        if (recipientType != NotificationRecipientType.PARENT_ONLY) {
            addDistinct(
                    recipientsByAccountId,
                    audienceRepository.findActiveStudentAccounts(
                            classId,
                            academicYearId
                    )
            );
        }
        if (recipientType != NotificationRecipientType.STUDENT_ONLY) {
            addDistinct(
                    recipientsByAccountId,
                    audienceRepository.findActiveParentAccounts(
                            classId,
                            academicYearId
                    )
            );
        }

        return List.copyOf(recipientsByAccountId.values());
    }

    private void addDistinct(
            Map<Long, Account> recipientsByAccountId,
            List<Account> accounts
    ) {
        accounts.forEach(account ->
                recipientsByAccountId.putIfAbsent(account.getId(), account)
        );
    }
}
