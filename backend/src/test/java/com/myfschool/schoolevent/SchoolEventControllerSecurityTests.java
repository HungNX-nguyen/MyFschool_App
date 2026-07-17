package com.myfschool.schoolevent;

import com.myfschool.account.RoleType;
import com.myfschool.schoolevent.dto.SchoolEventItemResponse;
import com.myfschool.schoolevent.dto.SchoolEventListResponse;
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
import java.time.LocalTime;
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
class SchoolEventControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private SchoolEventQueryService schoolEventQueryService;

    @Test
    void allowsParentToViewEventsForLinkedStudent() throws Exception {
        when(schoolEventQueryService.getParentStudentEvents(
                10L,
                30L,
                SchoolEventTimeRange.UPCOMING,
                SchoolEventViewScope.CLASS
        )).thenReturn(response(SchoolEventTimeRange.UPCOMING, SchoolEventViewScope.CLASS));

        mockMvc.perform(get("/api/v1/parent/students/30/events")
                        .param("timeRange", "UPCOMING")
                        .param("scope", "CLASS")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.studentId").value(30))
                .andExpect(jsonPath("$.data.classCode").value("10A1"))
                .andExpect(jsonPath("$.data.timeRange").value("UPCOMING"))
                .andExpect(jsonPath("$.data.scope").value("CLASS"))
                .andExpect(jsonPath("$.data.items[0].title")
                        .value("Họp phụ huynh lớp 10A1"));
    }

    @Test
    void allowsStudentToViewOwnEvents() throws Exception {
        when(schoolEventQueryService.getStudentEvents(
                10L,
                SchoolEventTimeRange.PAST,
                SchoolEventViewScope.SCHOOL
        )).thenReturn(response(SchoolEventTimeRange.PAST, SchoolEventViewScope.SCHOOL));

        mockMvc.perform(get("/api/v1/student/me/events")
                        .param("timeRange", "PAST")
                        .param("scope", "SCHOOL")
                        .with(authentication(authenticationFor(RoleType.STUDENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.timeRange").value("PAST"))
                .andExpect(jsonPath("$.data.scope").value("SCHOOL"))
                .andExpect(jsonPath("$.data.items[0].participationType")
                        .value("REQUIRED"));
    }

    @Test
    void rejectsCrossRoleAndUnauthenticatedAccess() throws Exception {
        mockMvc.perform(get("/api/v1/parent/students/30/events")
                        .with(authentication(authenticationFor(RoleType.STUDENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/student/me/events")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/student/me/events"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void returnsAccessibleEventDetailForParent() throws Exception {
        var item = response(
                SchoolEventTimeRange.UPCOMING,
                SchoolEventViewScope.CLASS
        ).items().get(0);
        when(schoolEventQueryService.getAccessibleEvent(
                10L,
                RoleType.PARENT,
                100L
        )).thenReturn(item);

        mockMvc.perform(get("/api/v1/school-events/100")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(100))
                .andExpect(jsonPath("$.data.classCode").value("10A1"));
    }

    private SchoolEventListResponse response(
            SchoolEventTimeRange timeRange,
            SchoolEventViewScope scope
    ) {
        return new SchoolEventListResponse(
                30L,
                40L,
                "10A1",
                timeRange,
                scope,
                List.of(new SchoolEventItemResponse(
                        100L,
                        "Họp phụ huynh lớp 10A1",
                        "Trao đổi kết quả học tập",
                        SchoolEventScope.CLASS,
                        40L,
                        "10A1",
                        LocalDate.of(2026, 8, 20),
                        LocalTime.of(8, 0),
                        LocalTime.of(10, 0),
                        false,
                        "Phòng A101",
                        SchoolEventParticipationType.REQUIRED
                ))
        );
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "school-event-test",
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
