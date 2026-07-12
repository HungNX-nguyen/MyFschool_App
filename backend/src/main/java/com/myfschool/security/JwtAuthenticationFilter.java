package com.myfschool.security;

import com.myfschool.account.AccountRoleStatus;
import com.myfschool.account.AccountRepository;
import com.myfschool.account.AccountStatus;
import com.myfschool.account.RoleType;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtService jwtService;
    private final AccountRepository accountRepository;
    private final RestAuthenticationEntryPoint authenticationEntryPoint;

    public JwtAuthenticationFilter(
            JwtService jwtService,
            AccountRepository accountRepository,
            RestAuthenticationEntryPoint authenticationEntryPoint
    ) {
        this.jwtService = jwtService;
        this.accountRepository = accountRepository;
        this.authenticationEntryPoint = authenticationEntryPoint;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        var authorization = request.getHeader("Authorization");
        if (authorization == null || !authorization.startsWith(BEARER_PREFIX)) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            authenticate(authorization.substring(BEARER_PREFIX.length()));
            filterChain.doFilter(request, response);
        } catch (JwtException | AuthenticationException exception) {
            SecurityContextHolder.clearContext();
            authenticationEntryPoint.commence(request, response, asAuthenticationException(exception));
        }
    }

    private void authenticate(String token) {
        var jwt = jwtService.decodeAccessToken(token);
        var accountId = Long.valueOf(jwt.getSubject());
        var account = accountRepository.findForSecurityById(accountId)
                .orElseThrow(() -> new BadCredentialsException("Account not found"));

        if (account.getStatus() != AccountStatus.ACTIVE) {
            throw new BadCredentialsException("Account is not active");
        }

        Set<RoleType> activeRoles = account.getRoles().stream()
                .filter(role -> role.getStatus() == AccountRoleStatus.ACTIVE)
                .map(role -> role.getRole())
                .collect(Collectors.toUnmodifiableSet());

        RoleType activeRole = parseActiveRole(jwt.getClaimAsString("activeRole"));
        if (activeRole != null && !activeRoles.contains(activeRole)) {
            throw new BadCredentialsException("Active role is no longer available");
        }

        var authorities = activeRole == null
                ? Set.<SimpleGrantedAuthority>of()
                : Set.of(new SimpleGrantedAuthority("ROLE_" + activeRole.name()));
        var principal = new AuthenticatedAccountPrincipal(
                account.getId(),
                account.getUsername(),
                activeRoles,
                activeRole
        );
        var authentication = new UsernamePasswordAuthenticationToken(
                principal,
                token,
                authorities
        );

        var context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    private RoleType parseActiveRole(String role) {
        if (role == null) {
            return null;
        }
        try {
            return RoleType.valueOf(role);
        } catch (IllegalArgumentException exception) {
            throw new BadCredentialsException("Invalid active role", exception);
        }
    }

    private AuthenticationException asAuthenticationException(Exception exception) {
        if (exception instanceof AuthenticationException authenticationException) {
            return authenticationException;
        }
        return new BadCredentialsException("Invalid access token", exception);
    }
}
