package com.myfschool.homeroom.dto;

import java.util.List;

public record HomeroomClassRosterResponse(
        Long classId,
        String classCode,
        String className,
        Long academicYearId,
        String academicYearName,
        int totalStudents,
        List<HomeroomStudentResponse> students
) {
}
