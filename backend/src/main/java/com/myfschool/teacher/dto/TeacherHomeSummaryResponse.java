package com.myfschool.teacher.dto;

import java.util.List;

public record TeacherHomeSummaryResponse(
        Long teacherId,
        String teacherCode,
        String teacherName,
        Long academicYearId,
        String academicYearName,
        List<TeacherHomeroomClassResponse> homeroomClasses,
        List<TeacherAssignmentResponse> teachingAssignments
) {
}
