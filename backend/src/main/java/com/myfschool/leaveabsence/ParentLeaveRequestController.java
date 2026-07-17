package com.myfschool.leaveabsence;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.leaveabsence.dto.CreateLeaveRequestRequest;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/parent")
public class ParentLeaveRequestController {

    private final ParentLeaveRequestService parentLeaveRequestService;

    public ParentLeaveRequestController(
            ParentLeaveRequestService parentLeaveRequestService
    ) {
        this.parentLeaveRequestService = parentLeaveRequestService;
    }

    @GetMapping("/students/{studentId}/leave-requests")
    public ResponseEntity<ApiResponse<List<LeaveRequestResponse>>> getLeaveRequests(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long studentId,
            @RequestParam(required = false) LeaveRequestStatus status
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                parentLeaveRequestService.getLeaveRequests(
                        principal.accountId(),
                        studentId,
                        status
                )
        ));
    }

    @PostMapping("/students/{studentId}/leave-requests")
    public ResponseEntity<ApiResponse<LeaveRequestResponse>> createLeaveRequest(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long studentId,
            @Valid @RequestBody CreateLeaveRequestRequest request
    ) {
        var response = parentLeaveRequestService.createLeaveRequest(
                principal.accountId(),
                studentId,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    @PatchMapping("/leave-requests/{leaveRequestId}/cancel")
    public ResponseEntity<ApiResponse<LeaveRequestResponse>> cancelLeaveRequest(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long leaveRequestId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                parentLeaveRequestService.cancelLeaveRequest(
                        principal.accountId(),
                        leaveRequestId
                )
        ));
    }
}
