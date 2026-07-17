package com.myfschool.grade.dto;

import com.myfschool.grade.LearningResultPeriod;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CalculateLearningResultRequest(
        @NotNull Long classId,
        @NotNull Long academicYearId,
        @NotNull LearningResultPeriod period,
        @Size(max = 50) String conductLabel,
        @Size(max = 2000) String description
) {
}
