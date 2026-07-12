package com.myfschool.security;

import com.myfschool.account.RoleType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.BadJwtException;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTests {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        var properties = new JwtProperties(
                "test-only-myfschool-jwt-secret-with-at-least-thirty-two-characters",
                3600,
                604800
        );
        jwtService = new JwtService(properties);
    }

    @Test
    void issuesAccessTokenWithAccountRolesAndActiveRole() {
        var tokens = jwtService.issueTokenPair(
                10L,
                Set.of(RoleType.PARENT, RoleType.TEACHER),
                RoleType.PARENT
        );

        var accessToken = jwtService.decodeAccessToken(tokens.accessToken());

        assertThat(accessToken.getSubject()).isEqualTo("10");
        assertThat(accessToken.getClaimAsStringList("roles"))
                .containsExactly("PARENT", "TEACHER");
        assertThat(accessToken.getClaimAsString("activeRole")).isEqualTo("PARENT");
        assertThat(tokens.tokenType()).isEqualTo("Bearer");
        assertThat(tokens.expiresIn()).isEqualTo(3600);
    }

    @Test
    void supportsAccessTokenWithoutActiveRoleForMultiRoleSelection() {
        var tokens = jwtService.issueTokenPair(
                10L,
                Set.of(RoleType.PARENT, RoleType.TEACHER),
                null
        );

        var accessToken = jwtService.decodeAccessToken(tokens.accessToken());

        assertThat(accessToken.hasClaim("activeRole")).isFalse();
    }

    @Test
    void rejectsRefreshTokenWhenAccessTokenIsExpected() {
        var tokens = jwtService.issueTokenPair(
                10L,
                Set.of(RoleType.PARENT),
                RoleType.PARENT
        );

        assertThatThrownBy(() -> jwtService.decodeAccessToken(tokens.refreshToken()))
                .isInstanceOf(BadJwtException.class);
    }
}
