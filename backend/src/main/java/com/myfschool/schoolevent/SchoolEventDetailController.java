package com.myfschool.schoolevent;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.schoolevent.dto.SchoolEventItemResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/school-events")
public class SchoolEventDetailController {

    private final SchoolEventQueryService schoolEventQueryService;

    public SchoolEventDetailController(SchoolEventQueryService schoolEventQueryService) {
        this.schoolEventQueryService = schoolEventQueryService;
    }

    @GetMapping("/{eventId}")
    public ResponseEntity<ApiResponse<SchoolEventItemResponse>> getEvent(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long eventId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                schoolEventQueryService.getAccessibleEvent(
                        principal.accountId(),
                        principal.activeRole(),
                        eventId
                )
        ));
    }
}
