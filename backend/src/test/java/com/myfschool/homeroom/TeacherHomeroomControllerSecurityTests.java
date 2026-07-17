package com.myfschool.homeroom;

import com.myfschool.account.RoleType;
import com.myfschool.academic.SemesterStatus;
import com.myfschool.academic.TimetableService;
import com.myfschool.homeroom.dto.HomeroomClassRosterResponse;
import com.myfschool.homeroom.dto.HomeroomClassSummaryResponse;
import com.myfschool.homeroom.dto.HomeroomSemesterResponse;
import com.myfschool.homeroom.dto.HomeroomTimetableResponse;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ActiveProfiles("test")
@SpringBootTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureMockMvc
class TeacherHomeroomControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private TeacherHomeroomService teacherHomeroomService;

    @MockitoBean
    private TimetableService timetableService;

    @Test
    void allowsTeacherToReadAllAssignedHomeroomClasses() throws Exception {
        when(teacherHomeroomService.getHomeroomClasses(10L))
                .thenReturn(List.of(classSummaryResponse()));

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].classCode").value("10A1"))
                .andExpect(jsonPath("$.data[0].academicYearName").value("2026-2027"))
                .andExpect(jsonPath("$.data[0].semesters[0].semesterId").value(5))
                .andExpect(jsonPath("$.data[0].semesters[0].status").value("PLANNED"));
    }

    @Test
    void allowsTeacherToReadHomeroomRoster() throws Exception {
        when(teacherHomeroomService.getClassRoster(10L, 30L))
                .thenReturn(rosterResponse());

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes/30/students")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.classCode").value("10A1"))
                .andExpect(jsonPath("$.data.totalStudents").value(0));
    }

    @Test
    void allowsTeacherToReadHomeroomTimetable() throws Exception {
        when(timetableService.getHomeroomClassTimetable(
                10L,
                30L,
                5L,
                LocalDate.of(2026, 8, 3),
                null
        )).thenReturn(timetableResponse());

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes/30/timetable")
                        .param("semesterId", "5")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.days.length()").value(0));
    }

    @Test
    void rejectsParentAndUnauthenticatedUser() throws Exception {
        mockMvc.perform(get("/api/v1/teacher/homeroom/classes")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes/30/students")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes/30/timetable")
                        .param("weekStart", "2026-08-03"))
                .andExpect(status().isUnauthorized());
    }

    private HomeroomClassSummaryResponse classSummaryResponse() {
        return new HomeroomClassSummaryResponse(
                30L,
                "10A1",
                "Lớp 10A1",
                1L,
                "2026-2027",
                LocalDate.of(2026, 8, 1),
                LocalDate.of(2027, 5, 31),
                List.of(new HomeroomSemesterResponse(
                        5L,
                        "Học kỳ 1",
                        1,
                        LocalDate.of(2026, 8, 3),
                        LocalDate.of(2026, 12, 31),
                        SemesterStatus.PLANNED
                ))
        );
    }

    private HomeroomClassRosterResponse rosterResponse() {
        return new HomeroomClassRosterResponse(
                30L,
                "10A1",
                "Lớp 10A1",
                1L,
                "2026-2027",
                0,
                List.of()
        );
    }

    private HomeroomTimetableResponse timetableResponse() {
        return new HomeroomTimetableResponse(
                30L,
                "10A1",
                "Lớp 10A1",
                5L,
                "Học kỳ 1",
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9),
                null,
                List.of(),
                List.of()
        );
    }

    private UsernamePasswordAuthenticationToken authenticationFor(
            RoleType activeRole
    ) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "homeroom-test",
                Set.of(activeRole),
                activeRole
        );
        return UsernamePasswordAuthenticationToken.authenticated(
                principal,
                null,
                Set.of(new SimpleGrantedAuthority("ROLE_" + activeRole.name()))
        );
    }
}
