package com.myfschool.parent;

import com.myfschool.account.RoleType;
import com.myfschool.parent.dto.LinkedStudentResponse;
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
class ParentControllerSecurityTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ParentStudentService parentStudentService;

    @Test
    void allowsParentActiveRole() throws Exception {
        when(parentStudentService.getLinkedStudents(10L)).thenReturn(List.of(
                new LinkedStudentResponse(
                        30L,
                        "STU0030",
                        "Nguyễn Minh An",
                        null,
                        null,
                        "MOTHER",
                        true
                )
        ));

        mockMvc.perform(get("/api/v1/parent/students")
                        .with(authentication(authenticationFor(RoleType.PARENT))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].studentId").value(30))
                .andExpect(jsonPath("$.data[0].studentCode").value("STU0030"))
                .andExpect(jsonPath("$.data[0].isPrimaryContact").value(true));
    }

    @Test
    void rejectsTeacherActiveRoleEvenWhenAccountAlsoHasParentRole() throws Exception {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "teacher-parent",
                Set.of(RoleType.PARENT, RoleType.TEACHER),
                RoleType.TEACHER
        );
        var authentication = UsernamePasswordAuthenticationToken.authenticated(
                principal,
                null,
                Set.of(new SimpleGrantedAuthority("ROLE_TEACHER"))
        );

        mockMvc.perform(get("/api/v1/parent/students")
                        .with(authentication(authentication)))
                .andExpect(status().isForbidden());
    }

    @Test
    void rejectsUnauthenticatedRequest() throws Exception {
        mockMvc.perform(get("/api/v1/parent/students"))
                .andExpect(status().isUnauthorized());
    }

    private UsernamePasswordAuthenticationToken authenticationFor(RoleType activeRole) {
        var principal = new AuthenticatedAccountPrincipal(
                10L,
                "parent-test",
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
