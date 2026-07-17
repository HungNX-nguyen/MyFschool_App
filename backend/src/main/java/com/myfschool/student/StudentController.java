package com.myfschool.student;

import com.myfschool.academic.TimetableService;
import com.myfschool.academic.dto.TimetableResponse;
import com.myfschool.common.api.ApiResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/student")
public class StudentController {

    private final TimetableService timetableService;

    public StudentController(TimetableService timetableService) {
        this.timetableService = timetableService;
    }

    @GetMapping("/me/timetable")
    public ResponseEntity<ApiResponse<TimetableResponse>> getMyTimetable(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @RequestParam(required = false) Long semesterId,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate weekStart
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                timetableService.getStudentTimetable(
                        principal.accountId(),
                        semesterId,
                        weekStart
                )
        ));
    }
}
