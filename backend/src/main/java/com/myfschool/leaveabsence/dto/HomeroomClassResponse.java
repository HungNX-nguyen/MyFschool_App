package com.myfschool.leaveabsence.dto;

public record HomeroomClassResponse(
        Long classId,
        String classCode,
        String className,
        Long academicYearId,
        String academicYearName
) {
}
