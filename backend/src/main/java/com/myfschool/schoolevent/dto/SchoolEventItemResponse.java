package com.myfschool.schoolevent.dto;

import com.myfschool.schoolevent.SchoolEventParticipationType;
import com.myfschool.schoolevent.SchoolEventScope;

import java.time.LocalDate;
import java.time.LocalTime;

public record SchoolEventItemResponse(
        Long id,
        String title,
        String description,
        SchoolEventScope scope,
        Long classId,
        String classCode,
        LocalDate eventDate,
        LocalTime startTime,
        LocalTime endTime,
        boolean isAllDay,
        String location,
        SchoolEventParticipationType participationType
) {
}
