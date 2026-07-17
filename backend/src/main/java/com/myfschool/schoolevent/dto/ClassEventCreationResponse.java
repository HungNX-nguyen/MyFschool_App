package com.myfschool.schoolevent.dto;

import com.myfschool.schoolevent.SchoolEventStatus;

import java.time.LocalDateTime;

public record ClassEventCreationResponse(
        Long eventId,
        SchoolEventStatus status,
        LocalDateTime publishedAt
) {
}
