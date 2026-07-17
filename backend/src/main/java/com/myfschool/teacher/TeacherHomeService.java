package com.myfschool.teacher;

import com.myfschool.academic.AcademicYearRepository;
import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.teacher.dto.TeacherAssignmentResponse;
import com.myfschool.teacher.dto.TeacherHomeSummaryResponse;
import com.myfschool.teacher.dto.TeacherHomeroomClassResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TeacherHomeService {

    private final TeacherRepository teacherRepository;
    private final AcademicYearRepository academicYearRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final TeachingAssignmentRepository teachingAssignmentRepository;

    public TeacherHomeService(
            TeacherRepository teacherRepository,
            AcademicYearRepository academicYearRepository,
            SchoolClassRepository schoolClassRepository,
            TeachingAssignmentRepository teachingAssignmentRepository
    ) {
        this.teacherRepository = teacherRepository;
        this.academicYearRepository = academicYearRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.teachingAssignmentRepository = teachingAssignmentRepository;
    }

    @Transactional(readOnly = true)
    public TeacherHomeSummaryResponse getHomeSummary(Long accountId) {
        var teacher = teacherRepository
                .findByAccountIdAndStatus(accountId, TeacherStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ giáo viên"));
        var academicYear = academicYearRepository
                .findFirstByStatusOrderByStartDateDesc(AcademicYearStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Năm học đang hoạt động"
                ));

        var homeroomClasses = schoolClassRepository
                .findHomeroomClasses(teacher.getId(), academicYear.getId())
                .stream()
                .map(schoolClass -> new TeacherHomeroomClassResponse(
                        schoolClass.getId(),
                        schoolClass.getClassCode(),
                        schoolClass.getClassName()
                ))
                .toList();

        var teachingAssignments = teachingAssignmentRepository
                .findByTeacherAndAcademicYear(
                        teacher.getId(),
                        academicYear.getId(),
                        TeachingAssignmentStatus.ACTIVE
                )
                .stream()
                .map(assignment -> new TeacherAssignmentResponse(
                        assignment.getSubject().getId(),
                        assignment.getSubject().getSubjectCode(),
                        assignment.getSubject().getSubjectName(),
                        assignment.getSchoolClass().getId(),
                        assignment.getSchoolClass().getClassCode(),
                        assignment.getSchoolClass().getClassName()
                ))
                .distinct()
                .toList();

        return new TeacherHomeSummaryResponse(
                teacher.getId(),
                teacher.getTeacherCode(),
                teacher.getFullName(),
                academicYear.getId(),
                academicYear.getName(),
                homeroomClasses,
                teachingAssignments
        );
    }
}
