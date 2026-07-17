package com.myfschool.schoolevent;

import com.myfschool.schoolevent.dto.SchoolEventItemResponse;
import com.myfschool.schoolevent.dto.SchoolEventListResponse;
import com.myfschool.student.Student;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class SchoolEventMapper {

    public SchoolEventItemResponse toItemResponse(SchoolEvent event) {
        var schoolClass = event.getSchoolClass();
        return new SchoolEventItemResponse(
                event.getId(),
                event.getTitle(),
                event.getDescription(),
                event.getScope(),
                schoolClass == null ? null : schoolClass.getId(),
                schoolClass == null ? null : schoolClass.getClassCode(),
                event.getEventDate(),
                event.getStartTime(),
                event.getEndTime(),
                event.isAllDay(),
                event.getLocation(),
                event.getParticipationType()
        );
    }

    public SchoolEventListResponse toListResponse(
            Student student,
            SchoolEventTimeRange timeRange,
            SchoolEventViewScope scope,
            List<SchoolEvent> events
    ) {
        var schoolClass = student.getCurrentClass();
        return new SchoolEventListResponse(
                student.getId(),
                schoolClass == null ? null : schoolClass.getId(),
                schoolClass == null ? null : schoolClass.getClassCode(),
                timeRange,
                scope,
                events.stream().map(this::toItemResponse).toList()
        );
    }
}
