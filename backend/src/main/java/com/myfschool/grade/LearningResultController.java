package com.myfschool.grade;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.grade.dto.LearningResultResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LearningResultController {

    private final LearningResultQueryService learningResultQueryService;

    public LearningResultController(
            LearningResultQueryService learningResultQueryService
    ) {
        this.learningResultQueryService = learningResultQueryService;
    }

    @GetMapping("/api/v1/parent/students/{studentId}/learning-results")
    public ResponseEntity<ApiResponse<LearningResultResponse>> getParentStudentResult(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long studentId,
            @RequestParam(required = false) Long academicYearId,
            @RequestParam LearningResultPeriod period
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                learningResultQueryService.getParentStudentResult(
                        principal.accountId(),
                        studentId,
                        academicYearId,
                        period
                )
        ));
    }

    @GetMapping("/api/v1/student/me/learning-results")
    public ResponseEntity<ApiResponse<LearningResultResponse>> getStudentResult(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @RequestParam(required = false) Long academicYearId,
            @RequestParam LearningResultPeriod period
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                learningResultQueryService.getStudentResult(
                        principal.accountId(),
                        academicYearId,
                        period
                )
        ));
    }
}
