package com.myfschool.teacher.dto;

public record TeacherAssignmentResponse(
        Long subjectId,
        String subjectCode,
        String subjectName,
        Long classId,
        String classCode,
        String className
) {
}
