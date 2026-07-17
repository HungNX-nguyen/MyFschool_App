package com.myfschool.schoolevent;

import com.myfschool.account.RoleType;
import com.myfschool.schoolevent.dto.ClassEventCreationResponse;
import com.myfschool.schoolevent.dto.CreateClassEventRequest;
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
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Set;

import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ActiveProfiles("test")
@SpringBootTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureMockMvc
class TeacherClassEventControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private TeacherClassEventService teacherClassEventService;

    @Test
    void allowsTeacherToPublishClassEvent() throws Exception {
        var request = request(true);
        when(teacherClassEventService.createClassEvent(10L, 30L, request))
                .thenReturn(new ClassEventCreationResponse(
                        50L,
                        SchoolEventStatus.PUBLISHED,
                        LocalDateTime.of(2026, 7, 17, 11, 0)
                ));

        mockMvc.perform(post("/api/v1/teacher/homeroom/classes/30/events")
                        .contentType("application/json")
                        .content(validJson(true))
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.eventId").value(50))
                .andExpect(jsonPath("$.data.status").value("PUBLISHED"));
    }

    @Test
    void validatesRequestBeforeCallingService() throws Exception {
        mockMvc.perform(post("/api/v1/teacher/homeroom/classes/30/events")
                        .contentType("application/json")
                        .content("""
                                {
                                  "title": " ",
                                  "eventDate": null,
                                  "allDay": null,
                                  "participationType": null,
                                  "publishNow": null
                                }
                                """)
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"));

        verify(teacherClassEventService, never())
                .createClassEvent(org.mockito.ArgumentMatchers.any(),
                        org.mockito.ArgumentMatchers.any(),
                        org.mockito.ArgumentMatchers.any());
    }

    @Test
    void rejectsParentAndUnauthenticatedUser() throws Exception {
        mockMvc.perform(post("/api/v1/teacher/homeroom/classes/30/events")
                        .contentType("application/json")
                        .content(validJson(false))
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(post("/api/v1/teacher/homeroom/classes/30/events")
                        .contentType("application/json")
                        .content(validJson(false)))
                .andExpect(status().isUnauthorized());
    }

    private CreateClassEventRequest request(boolean publishNow) {
        return new CreateClassEventRequest(
                "Họp phụ huynh",
                "Họp tại lớp 10A1.",
                LocalDate.of(2026, 8, 15),
                false,
                LocalTime.of(8, 0),
                LocalTime.of(10, 0),
                "Phòng A101",
                SchoolEventParticipationType.REQUIRED,
                publishNow
        );
    }

    private String validJson(boolean publishNow) {
        return """
                {
                  "title": "Họp phụ huynh",
                  "description": "Họp tại lớp 10A1.",
                  "eventDate": "2026-08-15",
                  "allDay": false,
                  "startTime": "08:00:00",
                  "endTime": "10:00:00",
                  "location": "Phòng A101",
                  "participationType": "REQUIRED",
                  "publishNow": %s
                }
                """.formatted(publishNow);
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "class-event-test",
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
