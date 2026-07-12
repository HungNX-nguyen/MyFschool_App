package com.myfschool.security;

import com.myfschool.account.RoleType;

import java.security.Principal;
import java.util.Set;

public record AuthenticatedAccountPrincipal(
        Long accountId,
        String username,
        Set<RoleType> roles,
        RoleType activeRole
) implements Principal {
    public AuthenticatedAccountPrincipal {
        roles = Set.copyOf(roles);
    }

    @Override
    public String getName() {
        return accountId.toString();
    }
}
