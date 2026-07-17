package com.myfschool.notification;

import com.myfschool.account.RoleType;
import com.myfschool.notification.dto.MarkAllNotificationsReadResponse;
import com.myfschool.notification.dto.NotificationDetailResponse;
import com.myfschool.notification.dto.NotificationItemResponse;
import com.myfschool.notification.dto.NotificationNavigationTargetResponse;
import com.myfschool.notification.dto.NotificationPageResponse;
import com.myfschool.notification.dto.UnreadNotificationCountResponse;
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
import java.util.List;
import java.util.Set;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ActiveProfiles("test")
@SpringBootTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureMockMvc
class MyNotificationControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private MyNotificationService myNotificationService;

    @Test
    void allowsAuthenticatedParentToViewOwnNotifications() throws Exception {
        when(myNotificationService.getMyNotifications(10L, false, 0, 20))
                .thenReturn(notificationPage());

        mockMvc.perform(get("/api/v1/notifications/me")
                        .param("isRead", "false")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.items[0].notificationId").value(101))
                .andExpect(jsonPath("$.data.items[0].type").value("EVENT"))
                .andExpect(jsonPath("$.data.items[0].isRead").value(false))
                .andExpect(jsonPath("$.data.unreadCount").value(3));
    }

    @Test
    void allowsAuthenticatedStudentToViewUnreadCount() throws Exception {
        when(myNotificationService.getMyUnreadCount(10L))
                .thenReturn(new UnreadNotificationCountResponse(3));

        mockMvc.perform(get("/api/v1/notifications/me/unread-count")
                        .with(authentication(authenticationFor(RoleType.STUDENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.unreadCount").value(3));
    }

    @Test
    void returnsDetailAndMarksSingleNotificationRead() throws Exception {
        when(myNotificationService.getMyNotification(10L, 101L))
                .thenReturn(notificationDetail(false, null));
        var readAt = LocalDateTime.of(2026, 7, 17, 10, 0);
        when(myNotificationService.markMyNotificationRead(10L, 101L))
                .thenReturn(notificationDetail(true, readAt));

        var authentication = authentication(authenticationFor(RoleType.PARENT));
        mockMvc.perform(get("/api/v1/notifications/me/101")
                        .with(authentication))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content")
                        .value("Sự kiện lớp mới đã được phát hành."))
                .andExpect(jsonPath("$.data.navigationTarget.type")
                        .value("SCHOOL_EVENT"))
                .andExpect(jsonPath("$.data.navigationTarget.id").value(55));

        mockMvc.perform(patch("/api/v1/notifications/me/101/read")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isRead").value(true))
                .andExpect(jsonPath("$.data.readAt").exists());
    }

    @Test
    void marksAllNotificationsReadForAuthenticatedStudent() throws Exception {
        when(myNotificationService.markAllMyNotificationsRead(10L))
                .thenReturn(new MarkAllNotificationsReadResponse(3, 0));

        mockMvc.perform(patch("/api/v1/notifications/me/read-all")
                        .with(authentication(authenticationFor(RoleType.STUDENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.updatedCount").value(3))
                .andExpect(jsonPath("$.data.unreadCount").value(0));
    }

    @Test
    void rejectsUnauthenticatedAccess() throws Exception {
        mockMvc.perform(get("/api/v1/notifications/me"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(get("/api/v1/notifications/me/unread-count"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(patch("/api/v1/notifications/me/101/read"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(patch("/api/v1/notifications/me/read-all"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void rejectsMalformedPaginationAsInvalidRequest() throws Exception {
        mockMvc.perform(get("/api/v1/notifications/me")
                        .param("page", "not-a-number")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("INVALID_REQUEST"))
                .andExpect(jsonPath("$.error.details[0].field").value("page"));
    }

    private NotificationPageResponse notificationPage() {
        return new NotificationPageResponse(
                List.of(new NotificationItemResponse(
                        101L,
                        "Họp phụ huynh",
                        "Sự kiện lớp mới đã được phát hành.",
                        NotificationType.EVENT,
                        LocalDateTime.of(2026, 7, 17, 9, 30),
                        false,
                        null,
                        "SCHOOL_EVENT",
                        55L
                )),
                0,
                20,
                1,
                1,
                3
        );
    }

    private NotificationDetailResponse notificationDetail(
            boolean isRead,
            LocalDateTime readAt
    ) {
        return new NotificationDetailResponse(
                101L,
                "Họp phụ huynh",
                "Sự kiện lớp mới đã được phát hành.",
                NotificationType.EVENT,
                LocalDateTime.of(2026, 7, 17, 9, 30),
                isRead,
                readAt,
                "SCHOOL_EVENT",
                55L,
                new NotificationNavigationTargetResponse("SCHOOL_EVENT", 55L)
        );
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "my-notification-test",
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
