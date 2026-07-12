package com.myfschool.auth;

import com.myfschool.account.Account;
import com.myfschool.account.AccountRepository;
import com.myfschool.account.AccountRoleStatus;
import com.myfschool.account.AccountStatus;
import com.myfschool.account.RoleType;
import com.myfschool.auth.dto.ActiveRoleRequest;
import com.myfschool.auth.dto.AuthResponse;
import com.myfschool.auth.dto.LoginRequest;
import com.myfschool.auth.dto.RefreshTokenRequest;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.security.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class AuthService {

    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthMapper authMapper;

    public AuthService(
            AccountRepository accountRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthMapper authMapper
    ) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authMapper = authMapper;
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        var identifier = request.username().trim();
        var account = accountRepository.findForAuthentication(identifier)
                .orElseThrow(this::invalidCredentials);

        validateAccountStatus(account);
        if (!matchesPassword(request.password(), account.getPasswordHash())) {
            throw invalidCredentials();
        }

        var activeRoles = getActiveRoles(account);
        var activeRole = activeRoles.size() == 1
                ? activeRoles.iterator().next()
                : null;

        account.markLoginSuccessful(LocalDateTime.now());
        var tokens = jwtService.issueTokenPair(account.getId(), activeRoles, activeRole);
        return authMapper.toResponse(account, activeRole, tokens);
    }

    @Transactional(readOnly = true)
    public AuthResponse refresh(RefreshTokenRequest request) {
        var jwt = decodeRefreshToken(request.refreshToken());
        var account = loadAccountFromToken(jwt);
        var activeRoles = getActiveRoles(account);
        var activeRole = parseActiveRole(jwt.getClaimAsString("activeRole"));

        if (activeRole != null && !activeRoles.contains(activeRole)) {
            throw new BusinessException(
                    ErrorCode.AUTH_ROLE_NOT_AVAILABLE,
                    HttpStatus.FORBIDDEN,
                    "Vai trò đang sử dụng không còn hiệu lực"
            );
        }

        var tokens = jwtService.issueTokenPair(account.getId(), activeRoles, activeRole);
        return authMapper.toResponse(account, activeRole, tokens);
    }

    @Transactional(readOnly = true)
    public AuthResponse selectActiveRole(Long accountId, ActiveRoleRequest request) {
        var account = loadActiveAccount(accountId);
        var activeRoles = getActiveRoles(account);

        if (!activeRoles.contains(request.activeRole())) {
            throw new BusinessException(
                    ErrorCode.AUTH_ROLE_NOT_AVAILABLE,
                    HttpStatus.FORBIDDEN,
                    "Tài khoản không có vai trò được chọn"
            );
        }

        var tokens = jwtService.issueTokenPair(
                account.getId(),
                activeRoles,
                request.activeRole()
        );
        return authMapper.toResponse(account, request.activeRole(), tokens);
    }

    private Account loadAccountFromToken(Jwt jwt) {
        try {
            return loadActiveAccount(Long.valueOf(jwt.getSubject()));
        } catch (NumberFormatException exception) {
            throw invalidRefreshToken();
        }
    }

    private Account loadActiveAccount(Long accountId) {
        var account = accountRepository.findForSecurityById(accountId)
                .orElseThrow(this::invalidRefreshToken);
        validateAccountStatus(account);
        return account;
    }

    private Set<RoleType> getActiveRoles(Account account) {
        var activeRoles = account.getRoles().stream()
                .filter(role -> role.getStatus() == AccountRoleStatus.ACTIVE)
                .map(role -> role.getRole())
                .collect(Collectors.toUnmodifiableSet());

        if (activeRoles.isEmpty()) {
            throw new BusinessException(
                    ErrorCode.AUTH_ROLE_NOT_AVAILABLE,
                    HttpStatus.FORBIDDEN,
                    "Tài khoản không có vai trò đang hoạt động"
            );
        }
        return activeRoles;
    }

    private void validateAccountStatus(Account account) {
        if (account.getStatus() == AccountStatus.LOCKED) {
            throw new BusinessException(
                    ErrorCode.AUTH_ACCOUNT_LOCKED,
                    HttpStatus.FORBIDDEN,
                    "Tài khoản đã bị khóa"
            );
        }
        if (account.getStatus() == AccountStatus.INACTIVE) {
            throw new BusinessException(
                    ErrorCode.AUTH_ACCOUNT_INACTIVE,
                    HttpStatus.FORBIDDEN,
                    "Tài khoản chưa được kích hoạt"
            );
        }
        if (account.getStatus() == AccountStatus.PASSWORD_RESET_REQUIRED) {
            throw new BusinessException(
                    ErrorCode.AUTH_PASSWORD_RESET_REQUIRED,
                    HttpStatus.FORBIDDEN,
                    "Tài khoản cần đổi mật khẩu trước khi tiếp tục"
            );
        }
    }

    private boolean matchesPassword(String rawPassword, String passwordHash) {
        try {
            return passwordEncoder.matches(rawPassword, passwordHash);
        } catch (IllegalArgumentException exception) {
            return false;
        }
    }

    private Jwt decodeRefreshToken(String refreshToken) {
        try {
            return jwtService.decodeRefreshToken(refreshToken);
        } catch (JwtException exception) {
            throw invalidRefreshToken();
        }
    }

    private RoleType parseActiveRole(String role) {
        if (role == null) {
            return null;
        }
        try {
            return RoleType.valueOf(role);
        } catch (IllegalArgumentException exception) {
            throw invalidRefreshToken();
        }
    }

    private BusinessException invalidCredentials() {
        return new BusinessException(
                ErrorCode.AUTH_INVALID_CREDENTIALS,
                HttpStatus.UNAUTHORIZED,
                "Số điện thoại, tên đăng nhập hoặc mật khẩu không đúng"
        );
    }

    private BusinessException invalidRefreshToken() {
        return new BusinessException(
                ErrorCode.AUTH_TOKEN_EXPIRED,
                HttpStatus.UNAUTHORIZED,
                "Refresh token không hợp lệ hoặc đã hết hạn"
        );
    }
}
