package com.myfschool.leaveabsence;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.leaveabsence.dto.HomeroomClassResponse;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.leaveabsence.dto.ReviewLeaveRequestRequest;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/teacher")
public class TeacherLeaveRequestController {

    private final TeacherLeaveRequestService teacherLeaveRequestService;

    public TeacherLeaveRequestController(
            TeacherLeaveRequestService teacherLeaveRequestService
    ) {
        this.teacherLeaveRequestService = teacherLeaveRequestService;
    }

    @GetMapping("/me/homeroom-classes")
    public ResponseEntity<ApiResponse<List<HomeroomClassResponse>>> getHomeroomClasses(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                teacherLeaveRequestService.getHomeroomClasses(principal.accountId())
        ));
    }

    @GetMapping("/homeroom/classes/{classId}/leave-requests")
    public ResponseEntity<ApiResponse<List<LeaveRequestResponse>>> getLeaveRequests(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long classId,
            @RequestParam(required = false) LeaveRequestStatus status
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                teacherLeaveRequestService.getLeaveRequests(
                        principal.accountId(),
                        classId,
                        status
                )
        ));
    }

    @PatchMapping("/leave-requests/{leaveRequestId}/review")
    public ResponseEntity<ApiResponse<LeaveRequestResponse>> reviewLeaveRequest(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long leaveRequestId,
            @Valid @RequestBody ReviewLeaveRequestRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                teacherLeaveRequestService.reviewLeaveRequest(
                        principal.accountId(),
                        leaveRequestId,
                        request
                )
        ));
    }
}
