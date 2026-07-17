package com.myfschool.schoolevent;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.schoolevent.dto.SchoolEventListResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/parent")
public class ParentSchoolEventController {

    private final SchoolEventQueryService schoolEventQueryService;

    public ParentSchoolEventController(SchoolEventQueryService schoolEventQueryService) {
        this.schoolEventQueryService = schoolEventQueryService;
    }

    @GetMapping("/students/{studentId}/events")
    public ResponseEntity<ApiResponse<SchoolEventListResponse>> getStudentEvents(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long studentId,
            @RequestParam(required = false) SchoolEventTimeRange timeRange,
            @RequestParam(required = false) SchoolEventViewScope scope
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                schoolEventQueryService.getParentStudentEvents(
                        principal.accountId(),
                        studentId,
                        timeRange,
                        scope
                )
        ));
    }
}
