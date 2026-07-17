package com.myfschool.parent.dto;

public record LinkedStudentResponse(
        Long studentId,
        String studentCode,
        String fullName,
        Long classId,
        String className,
        String relationship,
        boolean isPrimaryContact
) {
}
