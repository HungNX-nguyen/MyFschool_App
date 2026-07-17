package com.myfschool.schoolevent;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.schoolevent.dto.ClassEventCreationResponse;
import com.myfschool.schoolevent.dto.CreateClassEventRequest;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/teacher/homeroom/classes/{classId}/events")
public class TeacherClassEventController {

    private final TeacherClassEventService teacherClassEventService;

    public TeacherClassEventController(
            TeacherClassEventService teacherClassEventService
    ) {
        this.teacherClassEventService = teacherClassEventService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ClassEventCreationResponse>> createClassEvent(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long classId,
            @Valid @RequestBody CreateClassEventRequest request
    ) {
        var response = teacherClassEventService.createClassEvent(
                principal.accountId(),
                classId,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Tạo sự kiện lớp thành công"));
    }
}
