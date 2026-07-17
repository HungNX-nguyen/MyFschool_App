package com.myfschool.academic.dto;

import com.myfschool.academic.LessonShift;

import java.time.LocalTime;

public record TimetableSlotResponse(
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
        String room,
        boolean fixedActivity
) {
}
