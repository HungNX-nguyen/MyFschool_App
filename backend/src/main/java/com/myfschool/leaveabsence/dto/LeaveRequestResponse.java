package com.myfschool.leaveabsence.dto;

import com.myfschool.leaveabsence.LeaveRequestStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record LeaveRequestResponse(
        Long id,
        Long studentId,
        String studentCode,
        String studentName,
        Long parentId,
        String parentName,
        Long classId,
        String classCode,
        String className,
        LocalDate fromDate,
        LocalDate toDate,
        String reason,
        LeaveRequestStatus status,
        Long reviewedByTeacherId,
        String reviewedByTeacherName,
        LocalDateTime reviewedAt,
        String reviewNote,
        LocalDateTime createdAt
) {
}
