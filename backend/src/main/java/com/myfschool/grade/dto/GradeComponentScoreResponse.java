package com.myfschool.grade.dto;

import java.math.BigDecimal;

public record GradeComponentScoreResponse(
        String componentCode,
        String componentName,
        Integer attemptNo,
        BigDecimal score
) {
}
