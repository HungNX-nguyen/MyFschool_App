package com.myfschool.homeroom.dto;

import com.myfschool.academic.SemesterStatus;

import java.time.LocalDate;

public record HomeroomSemesterResponse(
        Long semesterId,
        String semesterName,
        Integer semesterIndex,
        LocalDate startDate,
        LocalDate endDate,
        SemesterStatus status
) {
}
