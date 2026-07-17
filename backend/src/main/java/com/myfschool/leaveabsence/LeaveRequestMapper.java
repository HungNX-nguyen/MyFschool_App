package com.myfschool.leaveabsence;

import com.myfschool.academic.SchoolClass;
import com.myfschool.leaveabsence.dto.HomeroomClassResponse;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import org.springframework.stereotype.Component;

@Component
public class LeaveRequestMapper {

    public LeaveRequestResponse toResponse(LeaveRequest request) {
        var student = request.getStudent();
        var parent = request.getParent();
        var schoolClass = request.getSchoolClass();
        var reviewer = request.getReviewedByTeacher();

        return new LeaveRequestResponse(
                request.getId(),
                student.getId(),
                student.getStudentCode(),
                student.getFullName(),
                parent.getId(),
                parent.getFullName(),
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                request.getFromDate(),
                request.getToDate(),
                request.getReason(),
                request.getStatus(),
                reviewer == null ? null : reviewer.getId(),
                reviewer == null ? null : reviewer.getFullName(),
                request.getReviewedAt(),
                request.getReviewNote(),
                request.getCreatedAt()
        );
    }

    public HomeroomClassResponse toHomeroomClassResponse(SchoolClass schoolClass) {
        var academicYear = schoolClass.getAcademicYear();
        return new HomeroomClassResponse(
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                academicYear.getId(),
                academicYear.getName()
        );
    }
}
