package com.myfschool.grade.dto;

import com.myfschool.grade.LearningResultPeriod;

public record LearningResultCalculationResponse(
        Long studentId,
        Long classId,
        Long academicYearId,
        LearningResultPeriod period,
        boolean finalized
) {
}
