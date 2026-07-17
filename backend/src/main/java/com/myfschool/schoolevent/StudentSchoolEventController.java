package com.myfschool.schoolevent;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.schoolevent.dto.SchoolEventListResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/student")
public class StudentSchoolEventController {

    private final SchoolEventQueryService schoolEventQueryService;

    public StudentSchoolEventController(SchoolEventQueryService schoolEventQueryService) {
        this.schoolEventQueryService = schoolEventQueryService;
    }

    @GetMapping("/me/events")
    public ResponseEntity<ApiResponse<SchoolEventListResponse>> getMyEvents(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @RequestParam(required = false) SchoolEventTimeRange timeRange,
            @RequestParam(required = false) SchoolEventViewScope scope
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                schoolEventQueryService.getStudentEvents(
                        principal.accountId(),
                        timeRange,
                        scope
                )
        ));
    }
}
