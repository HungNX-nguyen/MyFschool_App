package com.myfschool.homeroom;

import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.academic.Semester;
import com.myfschool.academic.SemesterRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.homeroom.dto.HomeroomClassRosterResponse;
import com.myfschool.homeroom.dto.HomeroomClassSummaryResponse;
import com.myfschool.homeroom.dto.HomeroomSemesterResponse;
import com.myfschool.homeroom.dto.HomeroomStudentResponse;
import com.myfschool.student.StudentClassHistoryRepository;
import com.myfschool.student.StudentClassHistoryStatus;
import com.myfschool.student.StudentStatus;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class TeacherHomeroomService {

    private final TeacherRepository teacherRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SemesterRepository semesterRepository;
    private final StudentClassHistoryRepository studentClassHistoryRepository;

    public TeacherHomeroomService(
            TeacherRepository teacherRepository,
            SchoolClassRepository schoolClassRepository,
            SemesterRepository semesterRepository,
            StudentClassHistoryRepository studentClassHistoryRepository
    ) {
        this.teacherRepository = teacherRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.semesterRepository = semesterRepository;
        this.studentClassHistoryRepository = studentClassHistoryRepository;
    }

    @Transactional(readOnly = true)
    public List<HomeroomClassSummaryResponse> getHomeroomClasses(Long accountId) {
        var teacher = requireActiveTeacher(accountId);
        var homeroomClasses = schoolClassRepository
                .findAllHomeroomClasses(teacher.getId());
        if (homeroomClasses.isEmpty()) {
            return List.of();
        }
        var academicYearIds = homeroomClasses.stream()
                .map(schoolClass -> schoolClass.getAcademicYear().getId())
                .distinct()
                .toList();
        Map<Long, List<Semester>> semestersByAcademicYear = semesterRepository
                .findByAcademicYearIdInOrderByAcademicYearIdAscSemesterIndexAsc(
                        academicYearIds
                )
                .stream()
                .collect(Collectors.groupingBy(Semester::getAcademicYearId));

        return homeroomClasses.stream()
                .map(schoolClass -> {
                    var academicYear = schoolClass.getAcademicYear();
                    var semesters = semestersByAcademicYear
                            .getOrDefault(academicYear.getId(), List.of())
                            .stream()
                            .map(semester -> new HomeroomSemesterResponse(
                                    semester.getId(),
                                    semester.getName(),
                                    semester.getSemesterIndex(),
                                    semester.getStartDate(),
                                    semester.getEndDate(),
                                    semester.getStatus()
                            ))
                            .toList();
                    return new HomeroomClassSummaryResponse(
                            schoolClass.getId(),
                            schoolClass.getClassCode(),
                            schoolClass.getClassName(),
                            academicYear.getId(),
                            academicYear.getName(),
                            academicYear.getStartDate(),
                            academicYear.getEndDate(),
                            List.copyOf(semesters)
                    );
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public HomeroomClassRosterResponse getClassRoster(
            Long accountId,
            Long classId
    ) {
        var teacher = requireActiveTeacher(accountId);

        var schoolClass = schoolClassRepository
                .findHomeroomClass(
                        classId,
                        teacher.getId()
                )
                .orElseThrow(this::homeroomAccessDenied);
        var academicYear = schoolClass.getAcademicYear();

        List<HomeroomStudentResponse> students = studentClassHistoryRepository
                .findActiveStudentsForClassAndYear(
                        schoolClass.getId(),
                        academicYear.getId(),
                        StudentClassHistoryStatus.ACTIVE,
                        StudentStatus.ACTIVE
                )
                .stream()
                .map(student -> new HomeroomStudentResponse(
                        student.getId(),
                        student.getStudentCode(),
                        student.getFullName(),
                        student.getStatus()
                ))
                .toList();

        return new HomeroomClassRosterResponse(
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                academicYear.getId(),
                academicYear.getName(),
                students.size(),
                List.copyOf(students)
        );
    }

    private Teacher requireActiveTeacher(Long accountId) {
        return teacherRepository
                .findByAccountIdAndStatus(accountId, TeacherStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ giáo viên"));
    }

    private BusinessException homeroomAccessDenied() {
        return new BusinessException(
                ErrorCode.FORBIDDEN,
                HttpStatus.FORBIDDEN,
                "Bạn không có quyền xem lớp chủ nhiệm này"
        );
    }
}
