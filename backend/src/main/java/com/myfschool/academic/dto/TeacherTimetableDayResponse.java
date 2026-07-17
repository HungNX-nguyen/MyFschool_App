package com.myfschool.academic.dto;

import java.time.LocalDate;
import java.util.List;

public record TeacherTimetableDayResponse(
        int dayOfWeek,
        LocalDate date,
        List<TeacherTimetableSlotResponse> slots
) {
}
