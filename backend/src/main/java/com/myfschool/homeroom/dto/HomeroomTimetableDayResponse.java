package com.myfschool.homeroom.dto;

import java.time.LocalDate;
import java.util.List;

public record HomeroomTimetableDayResponse(
        int dayOfWeek,
        LocalDate date,
        List<HomeroomTimetableSlotResponse> slots
) {
}
