package com.myfschool.homeroom.dto;

import java.time.LocalDate;
import java.util.List;

public record HomeroomClassSummaryResponse(
        Long classId,
        String classCode,
        String className,
        Long academicYearId,
        String academicYearName,
        LocalDate academicYearStartDate,
        LocalDate academicYearEndDate,
        List<HomeroomSemesterResponse> semesters
) {
}
