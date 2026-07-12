package com.myfschool.common.api;

public record ApiErrorDetail(
        String field,
        String message
) {
}
