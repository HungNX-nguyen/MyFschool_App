package com.myfschool.homeroom.dto;

import com.myfschool.student.StudentStatus;

public record HomeroomStudentResponse(
        Long studentId,
        String studentCode,
        String fullName,
        StudentStatus status
) {
}
