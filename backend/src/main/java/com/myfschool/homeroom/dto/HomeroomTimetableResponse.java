package com.myfschool.homeroom.dto;

import java.time.LocalDate;
import java.util.List;

public record HomeroomTimetableResponse(
        Long classId,
        String classCode,
        String className,
        Long semesterId,
        String semesterName,
        LocalDate weekStart,
        LocalDate weekEnd,
        Long selectedStudyGroupId,
        List<HomeroomStudyGroupResponse> availableStudyGroups,
        List<HomeroomTimetableDayResponse> days
) {
}
