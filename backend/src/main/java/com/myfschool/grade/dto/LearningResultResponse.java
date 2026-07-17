package com.myfschool.grade.dto;

import com.myfschool.grade.LearningResultPeriod;

import java.math.BigDecimal;
import java.util.List;

public record LearningResultResponse(
        List<AcademicYearOptionResponse> availableAcademicYears,
        Long academicYearId,
        String academicYearName,
        LearningResultPeriod period,
        Long semesterId,
        String semesterName,
        boolean finalized,
        List<LearningResultSubjectResponse> subjects,
        BigDecimal overallAverage,
        String academicRank,
        String conductLabel,
        String description,
        String promotionStatus
) {
}
