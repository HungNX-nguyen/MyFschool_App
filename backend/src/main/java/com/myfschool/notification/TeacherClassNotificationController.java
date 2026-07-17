package com.myfschool.notification;

import com.myfschool.common.api.ApiResponse;
import com.myfschool.notification.dto.ClassNotificationResponse;
import com.myfschool.notification.dto.CreateClassNotificationRequest;
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
@RequestMapping("/api/v1/teacher/notifications")
public class TeacherClassNotificationController {

    private final ClassNotificationService classNotificationService;

    public TeacherClassNotificationController(
            ClassNotificationService classNotificationService
    ) {
        this.classNotificationService = classNotificationService;
    }

    @PostMapping("/classes/{classId}")
    public ResponseEntity<ApiResponse<ClassNotificationResponse>> sendClassNotification(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long classId,
            @Valid @RequestBody CreateClassNotificationRequest request
    ) {
        var response = classNotificationService.sendClassNotification(
                principal.accountId(),
                classId,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Gửi thông báo thành công"));
    }
}
