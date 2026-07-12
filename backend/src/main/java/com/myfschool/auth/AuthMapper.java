package com.myfschool.auth;

import com.myfschool.account.Account;
import com.myfschool.account.AccountRoleStatus;
import com.myfschool.account.RoleType;
import com.myfschool.auth.dto.AccountResponse;
import com.myfschool.auth.dto.AuthResponse;
import com.myfschool.security.JwtTokenPair;
import org.springframework.stereotype.Component;

@Component
public class AuthMapper {

    public AuthResponse toResponse(
            Account account,
            RoleType activeRole,
            JwtTokenPair tokens
    ) {
        var roles = account.getRoles().stream()
                .filter(role -> role.getStatus() == AccountRoleStatus.ACTIVE)
                .map(role -> role.getRole())
                .sorted()
                .toList();

        var accountResponse = new AccountResponse(
                account.getId(),
                account.getUsername(),
                roles,
                activeRole,
                account.getStatus(),
                null
        );

        return new AuthResponse(
                tokens.accessToken(),
                tokens.refreshToken(),
                tokens.tokenType(),
                tokens.expiresIn(),
                accountResponse
        );
    }
}
