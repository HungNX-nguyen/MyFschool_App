package com.myfschool.academic;

import com.myfschool.account.RoleType;
import com.myfschool.academic.dto.TeacherTimetableResponse;
import com.myfschool.academic.dto.TimetableResponse;
import com.myfschool.parent.ParentStudentService;
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
class TimetableControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private TimetableService timetableService;

    @MockitoBean
    private ParentStudentService parentStudentService;

    @Test
    void allowsParentToReadLinkedStudentTimetable() throws Exception {
        when(timetableService.getParentStudentTimetable(
                10L,
                30L,
                1L,
                LocalDate.of(2026, 8, 3)
        )).thenReturn(response());

        mockMvc.perform(get("/api/v1/parent/students/30/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.classCode").value("10A1"));
    }

    @Test
    void rejectsTeacherFromParentTimetableRoute() throws Exception {
        mockMvc.perform(get("/api/v1/parent/students/30/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isForbidden());
    }

    @Test
    void allowsStudentToReadOwnTimetable() throws Exception {
        when(timetableService.getStudentTimetable(
                10L,
                1L,
                LocalDate.of(2026, 8, 3)
        )).thenReturn(response());

        mockMvc.perform(get("/api/v1/student/me/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.STUDENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.days.length()").value(0));
    }

    @Test
    void rejectsParentFromStudentTimetableRoute() throws Exception {
        mockMvc.perform(get("/api/v1/student/me/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());
    }

    @Test
    void allowsTeacherToReadOwnTimetable() throws Exception {
        when(timetableService.getTeacherTimetable(
                10L,
                1L,
                LocalDate.of(2026, 8, 3)
        )).thenReturn(teacherResponse());

        mockMvc.perform(get("/api/v1/teacher/me/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.teacherCode").value("TCH010"))
                .andExpect(jsonPath("$.data.weekStart").value("2026-08-03"));
    }

    @Test
    void rejectsParentFromTeacherTimetableRoute() throws Exception {
        mockMvc.perform(get("/api/v1/teacher/me/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());
    }

    @Test
    void rejectsUnauthenticatedTimetableRequest() throws Exception {
        mockMvc.perform(get("/api/v1/student/me/timetable")
                        .param("semesterId", "1")
                        .param("weekStart", "2026-08-03"))
                .andExpect(status().isUnauthorized());
    }

    private TimetableResponse response() {
        return new TimetableResponse(
                100L,
                "10A1",
                "10A1",
                1L,
                "Học kỳ 1",
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9),
                List.of()
        );
    }

    private TeacherTimetableResponse teacherResponse() {
        return new TeacherTimetableResponse(
                10L,
                "TCH010",
                "Giáo viên Test",
                1L,
                "Học kỳ 1",
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9),
                List.of()
        );
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "timetable-test",
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
