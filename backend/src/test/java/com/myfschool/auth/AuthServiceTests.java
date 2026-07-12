package com.myfschool.auth;

import com.myfschool.account.Account;
import com.myfschool.account.AccountRepository;
import com.myfschool.account.AccountStatus;
import com.myfschool.account.RoleType;
import com.myfschool.auth.dto.LoginRequest;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.security.JwtService;
import com.myfschool.security.JwtTokenPair;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTests {

    @Mock
    private AccountRepository accountRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(
                accountRepository,
                passwordEncoder,
                jwtService,
                new AuthMapper()
        );
    }

    @Test
    void selectsOnlyRoleAutomaticallyWhenLoginSucceeds() {
        var account = activeAccount("parent01", RoleType.PARENT);
        when(accountRepository.findForAuthentication("parent01"))
                .thenReturn(Optional.of(account));
        when(passwordEncoder.matches("password123", account.getPasswordHash()))
                .thenReturn(true);
        when(jwtService.issueTokenPair(anyLong(), any(), any()))
                .thenReturn(tokens());

        var response = authService.login(new LoginRequest(" parent01 ", "password123"));

        assertThat(response.account().activeRole()).isEqualTo(RoleType.PARENT);
        assertThat(response.account().roles()).containsExactly(RoleType.PARENT);
        assertThat(account.getLastLoginAt()).isNotNull();
        verify(jwtService).issueTokenPair(1L, java.util.Set.of(RoleType.PARENT), RoleType.PARENT);
    }

    @Test
    void requiresRoleSelectionWhenAccountHasMultipleRoles() {
        var account = activeAccount("teacher-parent", RoleType.TEACHER, RoleType.PARENT);
        when(accountRepository.findForAuthentication("teacher-parent"))
                .thenReturn(Optional.of(account));
        when(passwordEncoder.matches("password123", account.getPasswordHash()))
                .thenReturn(true);
        when(jwtService.issueTokenPair(anyLong(), any(), any()))
                .thenReturn(tokens());

        var response = authService.login(
                new LoginRequest("teacher-parent", "password123")
        );

        assertThat(response.account().activeRole()).isNull();
        assertThat(response.account().roles())
                .containsExactly(RoleType.PARENT, RoleType.TEACHER);
    }

    @Test
    void rejectsInvalidPasswordWithoutRevealingAccountState() {
        var account = activeAccount("parent01", RoleType.PARENT);
        when(accountRepository.findForAuthentication("parent01"))
                .thenReturn(Optional.of(account));
        when(passwordEncoder.matches("wrong-password", account.getPasswordHash()))
                .thenReturn(false);

        assertThatThrownBy(() -> authService.login(
                new LoginRequest("parent01", "wrong-password")
        ))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode())
                                .isEqualTo(ErrorCode.AUTH_INVALID_CREDENTIALS));
    }

    @Test
    void rejectsLockedAccount() {
        var account = new Account(
                "locked01",
                null,
                null,
                "$2a$10$validHashForUnitTestOnly",
                AccountStatus.LOCKED
        );
        ReflectionTestUtils.setField(account, "id", 2L);
        account.addRole(RoleType.PARENT);
        when(accountRepository.findForAuthentication("locked01"))
                .thenReturn(Optional.of(account));

        assertThatThrownBy(() -> authService.login(
                new LoginRequest("locked01", "password123")
        ))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode())
                                .isEqualTo(ErrorCode.AUTH_ACCOUNT_LOCKED));
    }

    private Account activeAccount(String username, RoleType... roles) {
        var account = new Account(
                username,
                null,
                null,
                "$2a$10$validHashForUnitTestOnly",
                AccountStatus.ACTIVE
        );
        ReflectionTestUtils.setField(account, "id", 1L);
        for (var role : roles) {
            account.addRole(role);
        }
        return account;
    }

    private JwtTokenPair tokens() {
        return new JwtTokenPair(
                "access-token",
                "refresh-token",
                "Bearer",
                3600
        );
    }
}
