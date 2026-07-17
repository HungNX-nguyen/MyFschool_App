package com.myfschool.homeroom;

import com.myfschool.academic.TimetableService;
import com.myfschool.common.api.ApiResponse;
import com.myfschool.homeroom.dto.HomeroomClassRosterResponse;
import com.myfschool.homeroom.dto.HomeroomClassSummaryResponse;
import com.myfschool.homeroom.dto.HomeroomTimetableResponse;
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
@RequestMapping("/api/v1/teacher/homeroom")
public class TeacherHomeroomController {

    private final TeacherHomeroomService teacherHomeroomService;
    private final TimetableService timetableService;

    public TeacherHomeroomController(
            TeacherHomeroomService teacherHomeroomService,
            TimetableService timetableService
    ) {
        this.teacherHomeroomService = teacherHomeroomService;
        this.timetableService = timetableService;
    }

    @GetMapping("/classes")
    public ResponseEntity<ApiResponse<List<HomeroomClassSummaryResponse>>> getClasses(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                teacherHomeroomService.getHomeroomClasses(principal.accountId())
        ));
    }

    @GetMapping("/classes/{classId}/students")
    public ResponseEntity<ApiResponse<HomeroomClassRosterResponse>> getClassRoster(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long classId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                teacherHomeroomService.getClassRoster(
                        principal.accountId(),
                        classId
                )
        ));
    }

    @GetMapping("/classes/{classId}/timetable")
    public ResponseEntity<ApiResponse<HomeroomTimetableResponse>> getClassTimetable(
            @AuthenticationPrincipal AuthenticatedAccountPrincipal principal,
            @PathVariable Long classId,
            @RequestParam(required = false) Long semesterId,
            @RequestParam(required = false) Long studyGroupId,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate weekStart
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                timetableService.getHomeroomClassTimetable(
                        principal.accountId(),
                        classId,
                        semesterId,
                        weekStart,
                        studyGroupId
                )
        ));
    }
}
