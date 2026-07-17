package com.myfschool.academic.dto;

import java.time.LocalDate;
import java.util.List;

public record TeacherTimetableResponse(
        Long teacherId,
        String teacherCode,
        String teacherName,
        Long semesterId,
        String semesterName,
        LocalDate weekStart,
        LocalDate weekEnd,
        List<TeacherTimetableDayResponse> days
) {
}
