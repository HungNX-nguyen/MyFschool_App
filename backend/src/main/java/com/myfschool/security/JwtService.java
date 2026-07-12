package com.myfschool.security;

import com.myfschool.account.RoleType;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.BadJwtException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Set;

@Service
public class JwtService {

    private static final String ISSUER = "myfschool";
    private static final String ACCESS_TOKEN = "ACCESS";
    private static final String REFRESH_TOKEN = "REFRESH";

    private final JwtProperties properties;
    private final JwtEncoder encoder;
    private final JwtDecoder decoder;

    public JwtService(JwtProperties properties) {
        this.properties = properties;

        SecretKey secretKey = new SecretKeySpec(
                properties.secret().getBytes(StandardCharsets.UTF_8),
                "HmacSHA256"
        );

        this.encoder = NimbusJwtEncoder.withSecretKey(secretKey)
                .algorithm(MacAlgorithm.HS256)
                .build();

        var nimbusDecoder = NimbusJwtDecoder.withSecretKey(secretKey)
                .macAlgorithm(MacAlgorithm.HS256)
                .build();
        nimbusDecoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(ISSUER));
        this.decoder = nimbusDecoder;
    }

    public JwtTokenPair issueTokenPair(
            Long accountId,
            Set<RoleType> roles,
            RoleType activeRole
    ) {
        var accessToken = encode(
                accountId,
                roles,
                activeRole,
                ACCESS_TOKEN,
                properties.accessTokenExpirationSeconds()
        );
        var refreshToken = encode(
                accountId,
                roles,
                activeRole,
                REFRESH_TOKEN,
                properties.refreshTokenExpirationSeconds()
        );

        return new JwtTokenPair(
                accessToken,
                refreshToken,
                "Bearer",
                properties.accessTokenExpirationSeconds()
        );
    }

    public Jwt decodeAccessToken(String token) {
        return decodeExpectedType(token, ACCESS_TOKEN);
    }

    public Jwt decodeRefreshToken(String token) {
        return decodeExpectedType(token, REFRESH_TOKEN);
    }

    private String encode(
            Long accountId,
            Set<RoleType> roles,
            RoleType activeRole,
            String tokenType,
            long expirationSeconds
    ) {
        var now = Instant.now();
        var claimsBuilder = JwtClaimsSet.builder()
                .issuer(ISSUER)
                .issuedAt(now)
                .expiresAt(now.plusSeconds(expirationSeconds))
                .subject(accountId.toString())
                .claim("accountId", accountId)
                .claim("roles", roles.stream().map(Enum::name).sorted().toList())
                .claim("tokenType", tokenType);

        if (activeRole != null) {
            claimsBuilder.claim("activeRole", activeRole.name());
        }

        var header = JwsHeader.with(MacAlgorithm.HS256).build();
        var parameters = JwtEncoderParameters.from(header, claimsBuilder.build());
        return encoder.encode(parameters).getTokenValue();
    }

    private Jwt decodeExpectedType(String token, String expectedType) {
        var jwt = decoder.decode(token);
        var tokenType = jwt.getClaimAsString("tokenType");
        if (!expectedType.equals(tokenType)) {
            throw new BadJwtException("Unexpected JWT token type");
        }
        return jwt;
    }
}
