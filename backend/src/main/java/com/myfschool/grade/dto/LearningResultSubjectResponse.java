package com.myfschool.grade.dto;

import java.math.BigDecimal;
import java.util.List;

public record LearningResultSubjectResponse(
        Long subjectId,
        String subjectCode,
        String subjectName,
        BigDecimal averageScore,
        List<GradeComponentScoreResponse> componentScores
) {
}
