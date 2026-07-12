package com.myfschool.security;

public record JwtTokenPair(
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresIn
) {
}
