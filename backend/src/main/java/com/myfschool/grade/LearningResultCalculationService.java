package com.myfschool.grade;

import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.academic.Semester;
import com.myfschool.academic.SemesterRepository;
import com.myfschool.academic.Subject;
import com.myfschool.account.AccountRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.student.Student;
import com.myfschool.student.StudentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class LearningResultCalculationService {

    private static final String REGULAR_COMPONENT = "DDG_TX";
    private static final String MIDTERM_COMPONENT = "DDG_GK";
    private static final String FINAL_COMPONENT = "DDG_CK";
    private static final int RESULT_SCALE = 2;
    private static final RoundingMode RESULT_ROUNDING = RoundingMode.HALF_UP;

    private final GradeRepository gradeRepository;
    private final LearningResultRepository learningResultRepository;
    private final StudentRepository studentRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SemesterRepository semesterRepository;
    private final AccountRepository accountRepository;

    public LearningResultCalculationService(
            GradeRepository gradeRepository,
            LearningResultRepository learningResultRepository,
            StudentRepository studentRepository,
            SchoolClassRepository schoolClassRepository,
            SemesterRepository semesterRepository,
            AccountRepository accountRepository
    ) {
        this.gradeRepository = gradeRepository;
        this.learningResultRepository = learningResultRepository;
        this.studentRepository = studentRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.semesterRepository = semesterRepository;
        this.accountRepository = accountRepository;
    }

    @Transactional
    public void calculateAndFinalizeSemester(
            Long studentId,
            Long classId,
            Long semesterId,
            Long finalizedByAccountId,
            String conductLabel,
            String description
    ) {
        var student = loadStudent(studentId);
        var schoolClass = loadClass(classId);
        var semester = loadSemester(semesterId);
        var finalizedBy = accountRepository.findById(finalizedByAccountId)
                .orElseThrow(() -> new ResourceNotFoundException("Tài khoản chốt kết quả"));
        var grades = gradeRepository.findPublishedForSemester(studentId, classId, semesterId);
        if (grades.isEmpty()) {
            throw ruleViolation("Không có điểm đã công bố để tính kết quả học kỳ");
        }

        var gradesBySubject = groupBySubject(grades);
        var existingResults = learningResultRepository.findForScope(
                studentId,
                classId,
                semester.getAcademicYearId()
        );
        var finalizedAt = LocalDateTime.now();
        var changedResults = new ArrayList<LearningResult>();
        var subjectAverages = new ArrayList<BigDecimal>();

        for (var subjectGrades : gradesBySubject.values()) {
            var subject = subjectGrades.getFirst().getSubject();
            var average = calculateSubjectSemesterAverage(subject, subjectGrades);
            subjectAverages.add(average);

            var result = findOrCreate(
                    existingResults,
                    student,
                    schoolClass,
                    semester.getAcademicYearId(),
                    semester,
                    subject,
                    LearningResultType.SUBJECT_SEMESTER
            );
            result.finalizeSnapshot(
                    average,
                    null,
                    null,
                    null,
                    null,
                    finalizedBy,
                    finalizedAt
            );
            changedResults.add(result);
        }

        var semesterAverage = average(subjectAverages);
        var semesterSummary = findOrCreate(
                existingResults,
                student,
                schoolClass,
                semester.getAcademicYearId(),
                semester,
                null,
                LearningResultType.SEMESTER_SUMMARY
        );
        semesterSummary.finalizeSnapshot(
                semesterAverage,
                classifyAcademicPerformance(subjectAverages, semesterAverage),
                normalizeOptionalLabel(conductLabel),
                null,
                description,
                finalizedBy,
                finalizedAt
        );
        changedResults.add(semesterSummary);

        learningResultRepository.saveAll(changedResults);
    }

    @Transactional
    public void calculateAndFinalizeAnnual(
            Long studentId,
            Long classId,
            Long academicYearId,
            Long finalizedByAccountId,
            String conductLabel,
            String description
    ) {
        var student = loadStudent(studentId);
        var schoolClass = loadClass(classId);
        var finalizedBy = accountRepository.findById(finalizedByAccountId)
                .orElseThrow(() -> new ResourceNotFoundException("Tài khoản chốt kết quả"));
        var semesters = semesterRepository
                .findByAcademicYearIdOrderBySemesterIndexAsc(academicYearId);
        validateAnnualSemesters(semesters);

        var existingResults = learningResultRepository.findForScope(
                studentId,
                classId,
                academicYearId
        );
        validateFinalizedSemesterSummaries(existingResults, semesters);

        var semesterOne = semesters.getFirst();
        var semesterTwo = semesters.get(1);
        var semesterOneSubjects = subjectResultsBySemester(existingResults, semesterOne.getId());
        var semesterTwoSubjects = subjectResultsBySemester(existingResults, semesterTwo.getId());
        if (semesterOneSubjects.isEmpty()
                || !semesterOneSubjects.keySet().equals(semesterTwoSubjects.keySet())) {
            throw ruleViolation(
                    "Hai học kỳ phải có cùng danh sách môn đã chốt trước khi tính cả năm"
            );
        }

        var finalizedAt = LocalDateTime.now();
        var changedResults = new ArrayList<LearningResult>();
        var annualSubjectAverages = new ArrayList<BigDecimal>();

        for (var entry : semesterOneSubjects.entrySet()) {
            var semesterOneResult = entry.getValue();
            var semesterTwoResult = semesterTwoSubjects.get(entry.getKey());
            var annualAverage = semesterOneResult.getAverageScore()
                    .add(semesterTwoResult.getAverageScore().multiply(BigDecimal.TWO))
                    .divide(BigDecimal.valueOf(3), RESULT_SCALE, RESULT_ROUNDING);
            annualSubjectAverages.add(annualAverage);

            var annualSubjectResult = findOrCreate(
                    existingResults,
                    student,
                    schoolClass,
                    academicYearId,
                    null,
                    semesterOneResult.getSubject(),
                    LearningResultType.SUBJECT_ANNUAL
            );
            annualSubjectResult.finalizeSnapshot(
                    annualAverage,
                    null,
                    null,
                    null,
                    null,
                    finalizedBy,
                    finalizedAt
            );
            changedResults.add(annualSubjectResult);
        }

        var annualAverage = average(annualSubjectAverages);
        var annualRank = classifyAcademicPerformance(
                annualSubjectAverages,
                annualAverage
        );
        var annualSummary = findOrCreate(
                existingResults,
                student,
                schoolClass,
                academicYearId,
                null,
                null,
                LearningResultType.ANNUAL_SUMMARY
        );
        annualSummary.finalizeSnapshot(
                annualAverage,
                annualRank,
                normalizeOptionalLabel(conductLabel),
                promotionStatusFor(annualRank),
                description,
                finalizedBy,
                finalizedAt
        );
        changedResults.add(annualSummary);

        learningResultRepository.saveAll(changedResults);
    }

    private Student loadStudent(Long studentId) {
        return studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Học sinh"));
    }

    private SchoolClass loadClass(Long classId) {
        return schoolClassRepository.findById(classId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học"));
    }

    private Semester loadSemester(Long semesterId) {
        return semesterRepository.findById(semesterId)
                .orElseThrow(() -> new ResourceNotFoundException("Học kỳ"));
    }

    private Map<Long, List<Grade>> groupBySubject(List<Grade> grades) {
        var groupedGrades = new LinkedHashMap<Long, List<Grade>>();
        for (var grade : grades) {
            groupedGrades
                    .computeIfAbsent(grade.getSubject().getId(), ignored -> new ArrayList<>())
                    .add(grade);
        }
        return groupedGrades;
    }

    private BigDecimal calculateSubjectSemesterAverage(
            Subject subject,
            List<Grade> grades
    ) {
        var gradesByComponent = grades.stream()
                .collect(Collectors.groupingBy(
                        grade -> grade.getGradeComponent().getCode()
                ));
        var regularGrades = gradesByComponent.getOrDefault(REGULAR_COMPONENT, List.of());
        var midtermGrades = gradesByComponent.getOrDefault(MIDTERM_COMPONENT, List.of());
        var finalGrades = gradesByComponent.getOrDefault(FINAL_COMPONENT, List.of());

        if (regularGrades.isEmpty()
                || midtermGrades.size() != 1
                || finalGrades.size() != 1) {
            throw ruleViolation(
                    "Môn " + subject.getSubjectName()
                            + " cần ít nhất 1 ĐĐG_TX, đúng 1 ĐĐG_GK và đúng 1 ĐĐG_CK đã công bố"
            );
        }

        var includedGrades = new ArrayList<Grade>();
        includedGrades.addAll(regularGrades);
        includedGrades.add(midtermGrades.getFirst());
        includedGrades.add(finalGrades.getFirst());

        var weightedTotal = BigDecimal.ZERO;
        var totalWeight = BigDecimal.ZERO;
        for (var grade : includedGrades) {
            weightedTotal = weightedTotal.add(grade.getScore().multiply(grade.getWeight()));
            totalWeight = totalWeight.add(grade.getWeight());
        }
        return weightedTotal.divide(totalWeight, RESULT_SCALE, RESULT_ROUNDING);
    }

    private BigDecimal average(List<BigDecimal> values) {
        if (values.isEmpty()) {
            throw ruleViolation("Không có điểm trung bình để tổng hợp");
        }
        var total = values.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        return total.divide(BigDecimal.valueOf(values.size()), RESULT_SCALE, RESULT_ROUNDING);
    }

    private String classifyAcademicPerformance(
            List<BigDecimal> subjectAverages,
            BigDecimal semesterAverage
    ) {
        var minimum = subjectAverages.stream().min(BigDecimal::compareTo).orElseThrow();
        var subjectsAtLeastEight = subjectAverages.stream()
                .filter(score -> score.compareTo(BigDecimal.valueOf(8)) >= 0)
                .count();

        if (minimum.compareTo(BigDecimal.valueOf(7)) >= 0
                && subjectsAtLeastEight >= 6
                && semesterAverage.compareTo(BigDecimal.valueOf(8)) >= 0) {
            return "Xuất Sắc";
        }
        if (minimum.compareTo(BigDecimal.valueOf(7)) >= 0
                && subjectsAtLeastEight >= 3
                && semesterAverage.compareTo(BigDecimal.valueOf(7.5)) >= 0) {
            return "Giỏi";
        }
        if (minimum.compareTo(BigDecimal.valueOf(6)) >= 0
                && subjectsAtLeastEight >= 1
                && semesterAverage.compareTo(BigDecimal.valueOf(6)) >= 0) {
            return "Khá";
        }
        if (minimum.compareTo(BigDecimal.valueOf(5)) >= 0
                && semesterAverage.compareTo(BigDecimal.valueOf(5)) >= 0) {
            return "Trung Bình";
        }
        return "Yếu";
    }

    private String promotionStatusFor(String annualRank) {
        return "Yếu".equals(annualRank) ? "RETAINED" : "PROMOTED";
    }

    private void validateAnnualSemesters(List<Semester> semesters) {
        if (semesters.size() != 2
                || semesters.getFirst().getSemesterIndex() != 1
                || semesters.get(1).getSemesterIndex() != 2) {
            throw ruleViolation("Năm học phải có đủ học kỳ I và học kỳ II");
        }
    }

    private void validateFinalizedSemesterSummaries(
            List<LearningResult> results,
            List<Semester> semesters
    ) {
        var finalizedSemesterIds = results.stream()
                .filter(result -> result.getResultType() == LearningResultType.SEMESTER_SUMMARY)
                .filter(LearningResult::isFinalized)
                .map(LearningResult::getSemester)
                .filter(Objects::nonNull)
                .map(Semester::getId)
                .collect(Collectors.toSet());
        var expectedSemesterIds = semesters.stream()
                .map(Semester::getId)
                .collect(Collectors.toSet());
        if (!finalizedSemesterIds.containsAll(expectedSemesterIds)) {
            throw ruleViolation("Phải chốt kết quả học kỳ I và học kỳ II trước khi tính cả năm");
        }
    }

    private Map<Long, LearningResult> subjectResultsBySemester(
            List<LearningResult> results,
            Long semesterId
    ) {
        return results.stream()
                .filter(result -> result.getResultType() == LearningResultType.SUBJECT_SEMESTER)
                .filter(LearningResult::isFinalized)
                .filter(result -> result.getSemester() != null)
                .filter(result -> result.getSemester().getId().equals(semesterId))
                .filter(result -> result.getSubject() != null)
                .filter(result -> result.getAverageScore() != null)
                .collect(Collectors.toMap(
                        result -> result.getSubject().getId(),
                        Function.identity()
                ));
    }

    private LearningResult findOrCreate(
            List<LearningResult> existingResults,
            Student student,
            SchoolClass schoolClass,
            Long academicYearId,
            Semester semester,
            Subject subject,
            LearningResultType resultType
    ) {
        var semesterId = semester == null ? null : semester.getId();
        var subjectId = subject == null ? null : subject.getId();
        var existing = existingResults.stream()
                .filter(result -> result.getResultType() == resultType)
                .filter(result -> sameId(result.getSemester(), semesterId))
                .filter(result -> sameId(result.getSubject(), subjectId))
                .findFirst();
        if (existing.isPresent()) {
            return existing.get();
        }

        var created = new LearningResult(
                student,
                schoolClass,
                academicYearId,
                semester,
                subject,
                resultType
        );
        existingResults.add(created);
        return created;
    }

    private boolean sameId(Semester entity, Long expectedId) {
        return Objects.equals(entity == null ? null : entity.getId(), expectedId);
    }

    private boolean sameId(Subject entity, Long expectedId) {
        return Objects.equals(entity == null ? null : entity.getId(), expectedId);
    }

    private String normalizeOptionalLabel(String label) {
        if (label == null || label.isBlank()) {
            return null;
        }
        return label.trim();
    }

    private BusinessException ruleViolation(String message) {
        return new BusinessException(
                ErrorCode.BUSINESS_RULE_VIOLATION,
                HttpStatus.CONFLICT,
                message
        );
    }
}
