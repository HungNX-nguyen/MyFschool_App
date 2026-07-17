package com.myfschool.homeroom.dto;

import com.myfschool.academic.LessonShift;

import java.time.LocalTime;

public record HomeroomTimetableSlotResponse(
        Long timetableId,
        int slotIndex,
        int displaySlotIndex,
        LessonShift shift,
        LocalTime startTime,
        LocalTime endTime,
        Long subjectId,
        String subjectCode,
        String subjectName,
        Long teacherId,
        String teacherName,
        Long studyGroupId,
        String studyGroupCode,
        String studyGroupName,
        String room,
        boolean fixedActivity
) {
}
