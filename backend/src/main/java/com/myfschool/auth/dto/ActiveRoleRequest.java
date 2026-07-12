package com.myfschool.auth.dto;

import com.myfschool.account.RoleType;
import jakarta.validation.constraints.NotNull;

public record ActiveRoleRequest(
        @NotNull(message = "Vai trò cần được chọn")
        RoleType activeRole
) {
}
