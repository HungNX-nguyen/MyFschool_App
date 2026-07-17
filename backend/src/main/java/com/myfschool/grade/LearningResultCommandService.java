package com.myfschool.grade;

import com.myfschool.academic.SemesterRepository;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.grade.dto.CalculateClassLearningResultsRequest;
import com.myfschool.grade.dto.CalculateLearningResultRequest;
import com.myfschool.grade.dto.ClassLearningResultCalculationResponse;
import com.myfschool.grade.dto.LearningResultCalculationResponse;
import com.myfschool.student.StudentClassHistoryRepository;
import com.myfschool.student.StudentClassHistoryStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumSet;

@Service
public class LearningResultCommandService {

    private final LearningResultCalculationService calculationService;
    private final SemesterRepository semesterRepository;
    private final StudentClassHistoryRepository studentClassHistoryRepository;

    public LearningResultCommandService(
            LearningResultCalculationService calculationService,
            SemesterRepository semesterRepository,
            StudentClassHistoryRepository studentClassHistoryRepository
    ) {
        this.calculationService = calculationService;
        this.semesterRepository = semesterRepository;
        this.studentClassHistoryRepository = studentClassHistoryRepository;
    }

    public LearningResultCalculationResponse calculateAndFinalize(
            Long studentId,
            Long finalizedByAccountId,
            CalculateLearningResultRequest request
    ) {
        if (request.period().isAnnual()) {
            calculationService.calculateAndFinalizeAnnual(
                    studentId,
                    request.classId(),
                    request.academicYearId(),
                    finalizedByAccountId,
                    request.conductLabel(),
                    request.description()
            );
        } else {
            var semester = semesterRepository
                    .findByAcademicYearIdAndSemesterIndex(
                            request.academicYearId(),
                            request.period().getSemesterIndex()
                    )
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Học kỳ thuộc năm học được chọn"
                    ));
            calculationService.calculateAndFinalizeSemester(
                    studentId,
                    request.classId(),
                    semester.getId(),
                    finalizedByAccountId,
                    request.conductLabel(),
                    request.description()
            );
        }

        return new LearningResultCalculationResponse(
                studentId,
                request.classId(),
                request.academicYearId(),
                request.period(),
                true
        );
    }

    @Transactional
    public ClassLearningResultCalculationResponse calculateAndFinalizeClass(
            Long classId,
            Long finalizedByAccountId,
            CalculateClassLearningResultsRequest request
    ) {
        var studentIds = studentClassHistoryRepository.findStudentIdsForClassAndYear(
                classId,
                request.academicYearId(),
                EnumSet.of(
                        StudentClassHistoryStatus.ACTIVE,
                        StudentClassHistoryStatus.COMPLETED
                )
        );
        if (studentIds.isEmpty()) {
            throw new ResourceNotFoundException(
                    "Học sinh thuộc lớp trong năm học được chọn"
            );
        }

        var individualRequest = new CalculateLearningResultRequest(
                classId,
                request.academicYearId(),
                request.period(),
                request.defaultConductLabel(),
                null
        );
        for (var studentId : studentIds) {
            calculateAndFinalize(studentId, finalizedByAccountId, individualRequest);
        }

        return new ClassLearningResultCalculationResponse(
                classId,
                request.academicYearId(),
                request.period(),
                studentIds.size()
        );
    }
}
