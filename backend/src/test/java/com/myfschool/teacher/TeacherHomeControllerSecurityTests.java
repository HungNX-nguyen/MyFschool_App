package com.myfschool.teacher;

import com.myfschool.account.RoleType;
import com.myfschool.academic.TimetableService;
import com.myfschool.security.AuthenticatedAccountPrincipal;
import com.myfschool.teacher.dto.TeacherAssignmentResponse;
import com.myfschool.teacher.dto.TeacherHomeSummaryResponse;
import com.myfschool.teacher.dto.TeacherHomeroomClassResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

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
class TeacherHomeControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private TeacherHomeService teacherHomeService;

    @MockitoBean
    private TimetableService timetableService;

    @Test
    void allowsTeacherToReadOwnHomeSummary() throws Exception {
        when(teacherHomeService.getHomeSummary(10L)).thenReturn(response());

        mockMvc.perform(get("/api/v1/teacher/me/home-summary")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.teacherCode").value("TCH001"))
                .andExpect(jsonPath("$.data.academicYearName").value("2026-2027"))
                .andExpect(jsonPath("$.data.homeroomClasses[0].classCode")
                        .value("10A1"))
                .andExpect(jsonPath("$.data.teachingAssignments[0].subjectName")
                        .value("Toán"));
    }

    @Test
    void rejectsParentAndUnauthenticatedUser() throws Exception {
        mockMvc.perform(get("/api/v1/teacher/me/home-summary")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/teacher/me/home-summary"))
                .andExpect(status().isUnauthorized());
    }

    private TeacherHomeSummaryResponse response() {
        return new TeacherHomeSummaryResponse(
                20L,
                "TCH001",
                "Giáo viên Test",
                1L,
                "2026-2027",
                List.of(new TeacherHomeroomClassResponse(
                        40L,
                        "10A1",
                        "Lớp 10A1"
                )),
                List.of(new TeacherAssignmentResponse(
                        50L,
                        "TOAN",
                        "Toán",
                        40L,
                        "10A1",
                        "Lớp 10A1"
                ))
        );
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "teacher-home-test",
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
