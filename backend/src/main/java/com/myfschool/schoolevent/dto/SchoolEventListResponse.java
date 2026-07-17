package com.myfschool.schoolevent.dto;

import com.myfschool.schoolevent.SchoolEventTimeRange;
import com.myfschool.schoolevent.SchoolEventViewScope;

import java.util.List;

public record SchoolEventListResponse(
        Long studentId,
        Long classId,
        String classCode,
        SchoolEventTimeRange timeRange,
        SchoolEventViewScope scope,
        List<SchoolEventItemResponse> items
) {
}
