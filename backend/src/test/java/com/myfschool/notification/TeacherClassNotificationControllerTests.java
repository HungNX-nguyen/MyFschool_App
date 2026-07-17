package com.myfschool.notification;

import com.myfschool.account.RoleType;
import com.myfschool.notification.dto.ClassNotificationResponse;
import com.myfschool.notification.dto.CreateClassNotificationRequest;
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

import java.time.LocalDateTime;
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
class TeacherClassNotificationControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ClassNotificationService classNotificationService;

    @Test
    void allowsTeacherToSendClassNotification() throws Exception {
        var request = new CreateClassNotificationRequest(
                "Nhắc lịch kiểm tra",
                "Chuẩn bị bài ngày mai.",
                NotificationRecipientType.PARENT_AND_STUDENT
        );
        when(classNotificationService.sendClassNotification(10L, 30L, request))
                .thenReturn(new ClassNotificationResponse(
                        100L,
                        28,
                        LocalDateTime.of(2026, 7, 17, 10, 30)
                ));

        mockMvc.perform(post("/api/v1/teacher/notifications/classes/30")
                        .contentType("application/json")
                        .content("""
                                {
                                  "title": "Nhắc lịch kiểm tra",
                                  "content": "Chuẩn bị bài ngày mai.",
                                  "recipientType": "PARENT_AND_STUDENT"
                                }
                                """)
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.notificationId").value(100))
                .andExpect(jsonPath("$.data.recipientCount").value(28));
    }

    @Test
    void validatesRequestBeforeCallingService() throws Exception {
        mockMvc.perform(post("/api/v1/teacher/notifications/classes/30")
                        .contentType("application/json")
                        .content("""
                                {
                                  "title": " ",
                                  "content": " ",
                                  "recipientType": null
                                }
                                """)
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"));

        verify(classNotificationService, never())
                .sendClassNotification(org.mockito.ArgumentMatchers.any(),
                        org.mockito.ArgumentMatchers.any(),
                        org.mockito.ArgumentMatchers.any());
    }

    @Test
    void rejectsParentAndUnauthenticatedUser() throws Exception {
        var validJson = """
                {
                  "title": "Thông báo",
                  "content": "Nội dung",
                  "recipientType": "PARENT_ONLY"
                }
                """;

        mockMvc.perform(post("/api/v1/teacher/notifications/classes/30")
                        .contentType("application/json")
                        .content(validJson)
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(post("/api/v1/teacher/notifications/classes/30")
                        .contentType("application/json")
                        .content(validJson))
                .andExpect(status().isUnauthorized());
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "notification-test",
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
