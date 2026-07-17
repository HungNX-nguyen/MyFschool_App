package com.myfschool.notification;

import com.myfschool.account.Account;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationRecipientResolverTests {

    @Mock
    private NotificationAudienceRepository audienceRepository;

    @InjectMocks
    private NotificationRecipientResolver resolver;

    @Test
    void parentOnlyReturnsOnlyParentAccounts() {
        var parentAccount = account(201L);
        when(audienceRepository.findActiveParentAccounts(10L, 1L))
                .thenReturn(List.of(parentAccount));

        var result = resolver.resolve(
                10L,
                1L,
                NotificationRecipientType.PARENT_ONLY
        );

        assertThat(result).extracting(Account::getId).containsExactly(201L);
        verify(audienceRepository, never())
                .findActiveStudentAccounts(10L, 1L);
    }

    @Test
    void studentOnlyReturnsOnlyStudentAccounts() {
        var studentAccount = account(101L);
        when(audienceRepository.findActiveStudentAccounts(10L, 1L))
                .thenReturn(List.of(studentAccount));

        var result = resolver.resolve(
                10L,
                1L,
                NotificationRecipientType.STUDENT_ONLY
        );

        assertThat(result).extracting(Account::getId).containsExactly(101L);
        verify(audienceRepository, never())
                .findActiveParentAccounts(10L, 1L);
    }

    @Test
    void parentAndStudentDeduplicatesMultiRoleAndRepeatedParentAccounts() {
        var studentAccount = account(101L);
        var multiRoleAccount = account(102L);
        var parentWithTwoChildren = account(201L);
        when(audienceRepository.findActiveStudentAccounts(10L, 1L))
                .thenReturn(List.of(studentAccount, multiRoleAccount));
        when(audienceRepository.findActiveParentAccounts(10L, 1L))
                .thenReturn(List.of(
                        multiRoleAccount,
                        parentWithTwoChildren,
                        parentWithTwoChildren
                ));

        var result = resolver.resolve(
                10L,
                1L,
                NotificationRecipientType.PARENT_AND_STUDENT
        );

        assertThat(result)
                .extracting(Account::getId)
                .containsExactly(101L, 102L, 201L);
    }

    private Account account(Long id) {
        var account = mock(Account.class);
        when(account.getId()).thenReturn(id);
        return account;
    }
}
