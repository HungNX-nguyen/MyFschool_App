package com.myfschool.parent;

import com.myfschool.academic.TimetableService;
import com.myfschool.academic.dto.TimetableResponse;
import com.myfschool.common.api.ApiResponse;
import com.myfschool.parent.dto.LinkedStudentResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/parent")
public class ParentController {

    private final ParentStudentService parentStudentService;
    private final TimetableService timetableService;

    public ParentController(
            ParentStudentService parentStudentService,
            TimetableService timetableService
    ) {
        this.parentStudentService = parentStudentService;
        this.timetableService = timetableService;
    }

    @GetMapping("/students")
    public ResponseEntity<ApiResponse<List<LinkedStudentResponse>>> getLinkedStudents(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                parentStudentService.getLinkedStudents(principal.accountId())
        ));
    }

    @GetMapping("/students/{studentId}/timetable")
    public ResponseEntity<ApiResponse<TimetableResponse>> getStudentTimetable(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long studentId,
            @RequestParam(required = false) Long semesterId,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate weekStart
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                timetableService.getParentStudentTimetable(
                        principal.accountId(),
                        studentId,
                        semesterId,
                        weekStart
                )
        ));
    }
}
