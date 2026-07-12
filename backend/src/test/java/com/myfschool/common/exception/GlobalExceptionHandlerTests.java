package com.myfschool.common.exception;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static org.assertj.core.api.Assertions.assertThat;

class GlobalExceptionHandlerTests {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void returnsStableErrorCodeForBusinessException() {
        var exception = new BusinessException(
                ErrorCode.AUTH_INVALID_CREDENTIALS,
                HttpStatus.UNAUTHORIZED,
                "Thông tin đăng nhập không đúng"
        );

        var response = handler.handleBusinessException(exception);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isFalse();
        assertThat(response.getBody().error().code())
                .isEqualTo("AUTH_INVALID_CREDENTIALS");
    }

    @Test
    void hidesUnexpectedExceptionDetails() {
        var response = handler.handleUnexpectedException(
                new IllegalStateException("database password must not leak")
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().error().code())
                .isEqualTo("INTERNAL_SERVER_ERROR");
        assertThat(response.getBody().error().message())
                .doesNotContain("database password");
    }
}
