package com.myfschool.account;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class AccountRepositoryTests {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private EntityManager entityManager;

    @Test
    void findsAccountAndRolesByUsername() {
        var account = new Account(
                "student01",
                null,
                null,
                "$2a$10$test-password-hash",
                AccountStatus.ACTIVE
        );
        account.addRole(RoleType.STUDENT);
        accountRepository.saveAndFlush(account);
        entityManager.clear();

        var result = accountRepository.findForAuthentication("student01");

        assertThat(result).isPresent();
        assertThat(result.orElseThrow().getRoles())
                .extracting(AccountRole::getRole)
                .containsExactly(RoleType.STUDENT);
    }

    @Test
    void findsAccountByPhone() {
        var account = new Account(
                null,
                null,
                "0900000001",
                "$2a$10$test-password-hash",
                AccountStatus.ACTIVE
        );
        account.addRole(RoleType.PARENT);
        accountRepository.saveAndFlush(account);
        entityManager.clear();

        var result = accountRepository.findForAuthentication("0900000001");

        assertThat(result).isPresent();
        assertThat(result.orElseThrow().getPhone()).isEqualTo("0900000001");
    }
}
