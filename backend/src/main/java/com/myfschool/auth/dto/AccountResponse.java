package com.myfschool.auth.dto;

import com.myfschool.account.AccountStatus;
import com.myfschool.account.RoleType;

import java.util.List;

public record AccountResponse(
        Long id,
        String username,
        List<RoleType> roles,
        RoleType activeRole,
        AccountStatus status,
        String fullName
) {
    public AccountResponse {
        roles = List.copyOf(roles);
    }
}
