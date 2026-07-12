package com.myfschool.auth;

import com.myfschool.auth.dto.ActiveRoleRequest;
import com.myfschool.auth.dto.AuthResponse;
import com.myfschool.auth.dto.LoginRequest;
import com.myfschool.auth.dto.RefreshTokenRequest;
import com.myfschool.common.api.ApiResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                authService.login(request),
                "Đăng nhập thành công"
        ));
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                authService.refresh(request),
                "Làm mới token thành công"
        ));
    }

    @PostMapping("/active-role")
    public ResponseEntity<ApiResponse<AuthResponse>> selectActiveRole(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @Valid @RequestBody ActiveRoleRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                authService.selectActiveRole(principal.accountId(), request),
                "Cập nhật vai trò thành công"
        ));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout() {
        return ResponseEntity.ok(ApiResponse.success(null, "Đăng xuất thành công"));
    }
}
