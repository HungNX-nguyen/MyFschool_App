package com.myfschool.academic.dto;

import java.time.LocalDate;
import java.util.List;

public record TimetableDayResponse(
        int dayOfWeek,
        LocalDate date,
        List<TimetableSlotResponse> slots
) {
}
