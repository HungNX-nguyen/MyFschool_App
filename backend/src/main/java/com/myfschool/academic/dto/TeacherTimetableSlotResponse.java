package com.myfschool.academic.dto;

import com.myfschool.academic.LessonShift;

import java.time.LocalTime;

public record TeacherTimetableSlotResponse(
        Long timetableId,
        int slotIndex,
        int displaySlotIndex,
        LessonShift shift,
        LocalTime startTime,
        LocalTime endTime,
        Long subjectId,
        String subjectCode,
        String subjectName,
        Long classId,
        String classCode,
        String className,
        Long studyGroupId,
        String studyGroupName,
        String room,
        boolean fixedActivity
) {
}
