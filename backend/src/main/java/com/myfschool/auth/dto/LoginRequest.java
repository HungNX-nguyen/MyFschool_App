package com.myfschool.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @NotBlank(message = "Vui lòng nhập số điện thoại hoặc tên đăng nhập")
        @Size(max = 100, message = "Tên đăng nhập không được vượt quá 100 ký tự")
        String username,

        @NotBlank(message = "Vui lòng nhập mật khẩu")
        @Size(max = 128, message = "Mật khẩu không được vượt quá 128 ký tự")
        String password
) {
}
