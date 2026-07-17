package com.myfschool.grade;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.grade.dto.CalculateClassLearningResultsRequest;
import com.myfschool.grade.dto.CalculateLearningResultRequest;
import com.myfschool.grade.dto.ClassLearningResultCalculationResponse;
import com.myfschool.grade.dto.LearningResultCalculationResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LearningResultCalculationController {

    private final LearningResultCommandService commandService;

    public LearningResultCalculationController(
            LearningResultCommandService commandService
    ) {
        this.commandService = commandService;
    }

    @PostMapping("/api/v1/admin/students/{studentId}/learning-results/calculate")
    public ResponseEntity<ApiResponse<LearningResultCalculationResponse>> calculate(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long studentId,
            @Valid @RequestBody CalculateLearningResultRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                commandService.calculateAndFinalize(
                        studentId,
                        principal.accountId(),
                        request
                ),
                "Đã tính và chốt kết quả học tập"
        ));
    }

    @PostMapping("/api/v1/admin/classes/{classId}/learning-results/calculate")
    public ResponseEntity<ApiResponse<ClassLearningResultCalculationResponse>> calculateClass(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long classId,
            @Valid @RequestBody CalculateClassLearningResultsRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                commandService.calculateAndFinalizeClass(
                        classId,
                        principal.accountId(),
                        request
                ),
                "Đã tính và chốt kết quả học tập của lớp"
        ));
    }
}
