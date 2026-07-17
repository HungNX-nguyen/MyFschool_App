package com.myfschool.leaveabsence;

import com.myfschool.account.RoleType;
import com.myfschool.leaveabsence.dto.CreateLeaveRequestRequest;
import com.myfschool.leaveabsence.dto.HomeroomClassResponse;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.leaveabsence.dto.ReviewLeaveRequestRequest;
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
import java.util.List;
import java.util.Set;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ActiveProfiles("test")
@SpringBootTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureMockMvc
class LeaveRequestControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ParentLeaveRequestService parentLeaveRequestService;

    @MockitoBean
    private TeacherLeaveRequestService teacherLeaveRequestService;

    @Test
    void allowsParentToListCreateAndCancelOwnLeaveRequests() throws Exception {
        when(parentLeaveRequestService.getLeaveRequests(
                10L,
                30L,
                LeaveRequestStatus.PENDING
        )).thenReturn(List.of(response(LeaveRequestStatus.PENDING)));
        when(parentLeaveRequestService.createLeaveRequest(
                10L,
                30L,
                new CreateLeaveRequestRequest(
                        LocalDate.of(2026, 8, 10),
                        LocalDate.of(2026, 8, 11),
                        "Nghỉ ốm"
                )
        )).thenReturn(response(LeaveRequestStatus.PENDING));
        when(parentLeaveRequestService.cancelLeaveRequest(10L, 101L))
                .thenReturn(response(LeaveRequestStatus.CANCELLED));

        mockMvc.perform(get("/api/v1/parent/students/30/leave-requests")
                        .param("status", "PENDING")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].studentCode").value("STU0030"));

        mockMvc.perform(post("/api/v1/parent/students/30/leave-requests")
                        .contentType("application/json")
                        .content("""
                                {
                                  "fromDate": "2026-08-10",
                                  "toDate": "2026-08-11",
                                  "reason": "Nghỉ ốm"
                                }
                                """)
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.status").value("PENDING"));

        mockMvc.perform(patch("/api/v1/parent/leave-requests/101/cancel")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("CANCELLED"));
    }

    @Test
    void validatesParentCreateRequestBeforeCallingService() throws Exception {
        mockMvc.perform(post("/api/v1/parent/students/30/leave-requests")
                        .contentType("application/json")
                        .content("""
                                {
                                  "fromDate": "2026-08-10",
                                  "toDate": "2026-08-11",
                                  "reason": " "
                                }
                                """)
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"));
    }

    @Test
    void rejectsTeacherFromParentLeaveRequestApi() throws Exception {
        mockMvc.perform(get("/api/v1/parent/students/30/leave-requests")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isForbidden());
    }

    @Test
    void allowsTeacherToListHomeroomClassesAndPendingRequests() throws Exception {
        when(teacherLeaveRequestService.getHomeroomClasses(10L)).thenReturn(List.of(
                new HomeroomClassResponse(40L, "10A1", "Lớp 10A1", 1L, "2026-2027")
        ));
        when(teacherLeaveRequestService.getLeaveRequests(
                10L,
                40L,
                LeaveRequestStatus.PENDING
        )).thenReturn(List.of(response(LeaveRequestStatus.PENDING)));

        mockMvc.perform(get("/api/v1/teacher/me/homeroom-classes")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].classCode").value("10A1"));

        mockMvc.perform(get("/api/v1/teacher/homeroom/classes/40/leave-requests")
                        .param("status", "PENDING")
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].status").value("PENDING"));
    }

    @Test
    void allowsTeacherToReviewRequest() throws Exception {
        when(teacherLeaveRequestService.reviewLeaveRequest(
                10L,
                101L,
                new ReviewLeaveRequestRequest(
                        LeaveRequestStatus.APPROVED,
                        "Đồng ý"
                )
        )).thenReturn(response(LeaveRequestStatus.APPROVED));

        mockMvc.perform(patch("/api/v1/teacher/leave-requests/101/review")
                        .contentType("application/json")
                        .content("""
                                {
                                  "decision": "APPROVED",
                                  "reviewNote": "Đồng ý"
                                }
                                """)
                        .with(authentication(authenticationFor(RoleType.TEACHER))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("APPROVED"));
    }

    @Test
    void rejectsParentAndUnauthenticatedUserFromTeacherApi() throws Exception {
        mockMvc.perform(get("/api/v1/teacher/me/homeroom-classes")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/teacher/me/homeroom-classes"))
                .andExpect(status().isUnauthorized());
    }

    private LeaveRequestResponse response(LeaveRequestStatus status) {
        return new LeaveRequestResponse(
                101L,
                30L,
                "STU0030",
                "Học sinh Test",
                20L,
                "Phụ huynh Test",
                40L,
                "10A1",
                "Lớp 10A1",
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 11),
                "Nghỉ ốm",
                status,
                status == LeaveRequestStatus.APPROVED ? 50L : null,
                status == LeaveRequestStatus.APPROVED ? "Giáo viên Test" : null,
                status == LeaveRequestStatus.APPROVED
                        ? LocalDateTime.of(2026, 7, 16, 8, 0)
                        : null,
                status == LeaveRequestStatus.APPROVED ? "Đồng ý" : null,
                LocalDateTime.of(2026, 7, 15, 8, 0)
        );
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "leave-request-test",
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
