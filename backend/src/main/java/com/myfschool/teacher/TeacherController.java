package com.myfschool.teacher;

import com.myfschool.academic.TimetableService;
import com.myfschool.academic.dto.TeacherTimetableResponse;
import com.myfschool.common.api.ApiResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import com.myfschool.teacher.dto.TeacherHomeSummaryResponse;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/teacher")
public class TeacherController {

    private final TimetableService timetableService;
    private final TeacherHomeService teacherHomeService;

    public TeacherController(
            TimetableService timetableService,
            TeacherHomeService teacherHomeService
    ) {
        this.timetableService = timetableService;
        this.teacherHomeService = teacherHomeService;
    }

    @GetMapping("/me/home-summary")
    public ResponseEntity<ApiResponse<TeacherHomeSummaryResponse>> getMyHomeSummary(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                teacherHomeService.getHomeSummary(principal.accountId())
        ));
    }

    @GetMapping("/me/timetable")
    public ResponseEntity<ApiResponse<TeacherTimetableResponse>> getMyTimetable(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @RequestParam(required = false) Long semesterId,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate weekStart
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                timetableService.getTeacherTimetable(
                        principal.accountId(),
                        semesterId,
                        weekStart
                )
        ));
    }
}
