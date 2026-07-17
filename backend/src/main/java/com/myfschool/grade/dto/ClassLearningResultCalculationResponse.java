package com.myfschool.grade.dto;

import com.myfschool.grade.LearningResultPeriod;

public record ClassLearningResultCalculationResponse(
        Long classId,
        Long academicYearId,
        LearningResultPeriod period,
        int finalizedStudentCount
) {
}
