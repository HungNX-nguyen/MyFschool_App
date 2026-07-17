package com.myfschool.grade;

import com.myfschool.academic.AcademicYear;
import com.myfschool.academic.AcademicYearRepository;
import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.Semester;
import com.myfschool.academic.SemesterRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.grade.dto.AcademicYearOptionResponse;
import com.myfschool.grade.dto.GradeComponentScoreResponse;
import com.myfschool.grade.dto.LearningResultResponse;
import com.myfschool.grade.dto.LearningResultSubjectResponse;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStatus;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import com.myfschool.student.Student;
import com.myfschool.student.StudentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class LearningResultQueryService {

    private final LearningResultRepository learningResultRepository;
    private final GradeRepository gradeRepository;
    private final AcademicYearRepository academicYearRepository;
    private final SemesterRepository semesterRepository;
    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final StudentRepository studentRepository;

    public LearningResultQueryService(
            LearningResultRepository learningResultRepository,
            GradeRepository gradeRepository,
            AcademicYearRepository academicYearRepository,
            SemesterRepository semesterRepository,
            ParentRepository parentRepository,
            ParentStudentRepository parentStudentRepository,
            StudentRepository studentRepository
    ) {
        this.learningResultRepository = learningResultRepository;
        this.gradeRepository = gradeRepository;
        this.academicYearRepository = academicYearRepository;
        this.semesterRepository = semesterRepository;
        this.parentRepository = parentRepository;
        this.parentStudentRepository = parentStudentRepository;
        this.studentRepository = studentRepository;
    }

    @Transactional(readOnly = true)
    public LearningResultResponse getParentStudentResult(
            Long accountId,
            Long studentId,
            Long academicYearId,
            LearningResultPeriod period
    ) {
        var parent = parentRepository
                .findByAccountIdAndStatus(accountId, ParentStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ phụ huynh"));
        var linkedStudent = parentStudentRepository
                .findLinkedStudent(parent.getId(), studentId, ParentStudentStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.FORBIDDEN,
                        HttpStatus.FORBIDDEN,
                        "Bạn không có quyền xem kết quả học tập của học sinh này"
                ));

        return buildResponse(linkedStudent.getStudent(), academicYearId, period);
    }

    @Transactional(readOnly = true)
    public LearningResultResponse getStudentResult(
            Long accountId,
            Long academicYearId,
            LearningResultPeriod period
    ) {
        var student = studentRepository
                .findByAccountIdWithCurrentClass(accountId)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ học sinh"));
        return buildResponse(student, academicYearId, period);
    }

    private LearningResultResponse buildResponse(
            Student student,
            Long requestedAcademicYearId,
            LearningResultPeriod period
    ) {
        if (period == null) {
            throw new BusinessException(
                    ErrorCode.VALIDATION_ERROR,
                    HttpStatus.BAD_REQUEST,
                    "period là bắt buộc"
            );
        }

        var academicYear = resolveAcademicYear(requestedAcademicYearId);
        var availableYears = loadAvailableYears(student);
        var semester = resolveSemester(academicYear.getId(), period);
        var results = learningResultRepository.findFinalizedForStudentAndYear(
                student.getId(),
                academicYear.getId()
        );
        var summary = findSummary(results, semester, period);

        if (summary == null) {
            return emptyResponse(availableYears, academicYear, semester, period);
        }

        var subjectResultType = period.isAnnual()
                ? LearningResultType.SUBJECT_ANNUAL
                : LearningResultType.SUBJECT_SEMESTER;
        var componentGradesBySubject = loadComponentGradesBySubject(
                student.getId(),
                summary,
                semester,
                period
        );
        var subjects = results.stream()
                .filter(result -> result.getResultType() == subjectResultType)
                .filter(result -> belongsToPeriod(result, semester, period))
                .filter(result -> result.getSubject() != null)
                .sorted(Comparator.comparing(
                        result -> result.getSubject().getSubjectName()
                ))
                .map(result -> new LearningResultSubjectResponse(
                        result.getSubject().getId(),
                        result.getSubject().getSubjectCode(),
                        result.getSubject().getSubjectName(),
                        result.getAverageScore(),
                        toComponentScores(componentGradesBySubject.getOrDefault(
                                result.getSubject().getId(),
                                List.of()
                        ))
                ))
                .toList();

        return new LearningResultResponse(
                availableYears,
                academicYear.getId(),
                academicYear.getName(),
                period,
                semester == null ? null : semester.getId(),
                semester == null ? null : semester.getName(),
                true,
                subjects,
                summary.getAverageScore(),
                summary.getRankLabel(),
                summary.getConductLabel(),
                summary.getDescription(),
                summary.getPromotionStatus()
        );
    }

    private Map<Long, List<Grade>> loadComponentGradesBySubject(
            Long studentId,
            LearningResult summary,
            Semester semester,
            LearningResultPeriod period
    ) {
        if (period.isAnnual() || semester == null) {
            return Map.of();
        }
        return gradeRepository.findPublishedForSemester(
                        studentId,
                        summary.getSchoolClass().getId(),
                        semester.getId()
                )
                .stream()
                .collect(Collectors.groupingBy(
                        grade -> grade.getSubject().getId()
                ));
    }

    private List<GradeComponentScoreResponse> toComponentScores(
            List<Grade> grades
    ) {
        return grades.stream()
                .sorted(Comparator
                        .comparingInt((Grade grade) -> componentOrder(
                                grade.getGradeComponent().getCode()
                        ))
                        .thenComparing(Grade::getAttemptNo))
                .map(grade -> new GradeComponentScoreResponse(
                        grade.getGradeComponent().getCode(),
                        grade.getGradeComponent().getName(),
                        grade.getAttemptNo(),
                        grade.getScore()
                ))
                .toList();
    }

    private int componentOrder(String componentCode) {
        return switch (componentCode) {
            case "DDG_TX" -> 1;
            case "DDG_GK" -> 2;
            case "DDG_CK" -> 3;
            default -> 4;
        };
    }

    private AcademicYear resolveAcademicYear(Long academicYearId) {
        if (academicYearId != null) {
            return academicYearRepository.findById(academicYearId)
                    .orElseThrow(() -> new ResourceNotFoundException("Năm học"));
        }
        return academicYearRepository
                .findFirstByStatusOrderByStartDateDesc(AcademicYearStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Năm học đang hoạt động"));
    }

    private List<AcademicYearOptionResponse> loadAvailableYears(Student student) {
        var yearIds = new HashSet<>(
                learningResultRepository.findFinalizedAcademicYearIds(student.getId())
        );
        if (student.getCurrentClass() != null) {
            yearIds.add(student.getCurrentClass().getAcademicYear().getId());
        }
        if (yearIds.isEmpty()) {
            return List.of();
        }
        return academicYearRepository.findByIdInOrderByStartDateDesc(yearIds)
                .stream()
                .map(year -> new AcademicYearOptionResponse(year.getId(), year.getName()))
                .toList();
    }

    private Semester resolveSemester(
            Long academicYearId,
            LearningResultPeriod period
    ) {
        if (period.isAnnual()) {
            return null;
        }
        return semesterRepository.findByAcademicYearIdAndSemesterIndex(
                academicYearId,
                period.getSemesterIndex()
        ).orElse(null);
    }

    private LearningResult findSummary(
            List<LearningResult> results,
            Semester semester,
            LearningResultPeriod period
    ) {
        var summaryType = period.isAnnual()
                ? LearningResultType.ANNUAL_SUMMARY
                : LearningResultType.SEMESTER_SUMMARY;
        return results.stream()
                .filter(result -> result.getResultType() == summaryType)
                .filter(result -> belongsToPeriod(result, semester, period))
                .findFirst()
                .orElse(null);
    }

    private boolean belongsToPeriod(
            LearningResult result,
            Semester semester,
            LearningResultPeriod period
    ) {
        if (period.isAnnual()) {
            return result.getSemester() == null;
        }
        return semester != null
                && result.getSemester() != null
                && result.getSemester().getId().equals(semester.getId());
    }

    private LearningResultResponse emptyResponse(
            List<AcademicYearOptionResponse> availableYears,
            AcademicYear academicYear,
            Semester semester,
            LearningResultPeriod period
    ) {
        return new LearningResultResponse(
                availableYears,
                academicYear.getId(),
                academicYear.getName(),
                period,
                semester == null ? null : semester.getId(),
                semester == null ? null : semester.getName(),
                false,
                List.of(),
                null,
                null,
                null,
                null,
                null
        );
    }
}
