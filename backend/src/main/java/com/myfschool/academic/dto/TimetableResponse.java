package com.myfschool.academic.dto;

import java.time.LocalDate;
import java.util.List;

public record TimetableResponse(
        Long classId,
        String classCode,
        String className,
        Long semesterId,
        String semesterName,
        LocalDate weekStart,
        LocalDate weekEnd,
        List<TimetableDayResponse> days
) {
}
