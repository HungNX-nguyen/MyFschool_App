package com.myfschool.notification;

import com.myfschool.account.Account;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class NotificationAudienceRepositoryTests {

    @Autowired
    private NotificationAudienceRepository repository;

    @Autowired
    private EntityManager entityManager;

    @BeforeEach
    void setUp() {
        executeUpdate("""
                insert into academic_year
                    (id, name, start_date, end_date, status)
                values
                    (1, '2026-2027', '2026-08-01', '2027-05-31', 'ACTIVE')
                """);
        executeUpdate("""
                insert into class (id, academic_year_id, class_code, class_name)
                values
                    (10, 1, '10A1', 'Lớp 10A1'),
                    (11, 1, '10A2', 'Lớp 10A2')
                """);
        executeUpdate("""
                insert into account
                    (id, username, password_hash, status, created_at, updated_at)
                values
                    (101, 'student-active-1', 'hash', 'ACTIVE', current_timestamp, current_timestamp),
                    (102, 'student-locked', 'hash', 'LOCKED', current_timestamp, current_timestamp),
                    (103, 'student-active-2', 'hash', 'ACTIVE', current_timestamp, current_timestamp),
                    (104, 'student-other-class', 'hash', 'ACTIVE', current_timestamp, current_timestamp),
                    (201, 'parent-active', 'hash', 'ACTIVE', current_timestamp, current_timestamp),
                    (202, 'parent-locked', 'hash', 'LOCKED', current_timestamp, current_timestamp),
                    (203, 'parent-profile-inactive', 'hash', 'ACTIVE', current_timestamp, current_timestamp)
                """);
        executeUpdate("""
                insert into student
                    (id, account_id, student_code, full_name, current_class_id, status)
                values
                    (301, 101, 'STU301', 'Student Active 1', 10, 'ACTIVE'),
                    (302, 102, 'STU302', 'Student Locked Account', 10, 'ACTIVE'),
                    (303, 103, 'STU303', 'Student Active 2', 10, 'ACTIVE'),
                    (304, 104, 'STU304', 'Student Other Class', 11, 'ACTIVE'),
                    (305, null, 'STU305', 'Student No Account', 10, 'ACTIVE')
                """);
        executeUpdate("""
                insert into student_class_history
                    (id, student_id, class_id, academic_year_id,
                     start_date, end_date, status, note)
                values
                    (401, 301, 10, 1, '2026-08-01', null, 'ACTIVE', null),
                    (402, 302, 10, 1, '2026-08-01', null, 'ACTIVE', null),
                    (403, 303, 10, 1, '2026-08-01', null, 'ACTIVE', null),
                    (404, 304, 11, 1, '2026-08-01', null, 'ACTIVE', null),
                    (405, 305, 10, 1, '2026-08-01', null, 'ACTIVE', null)
                """);
        executeUpdate("""
                insert into parent (id, account_id, full_name, status)
                values
                    (501, 201, 'Parent Active', 'ACTIVE'),
                    (502, 202, 'Parent Locked Account', 'ACTIVE'),
                    (503, 203, 'Parent Profile Inactive', 'INACTIVE')
                """);
        executeUpdate("""
                insert into parent_student
                    (id, parent_id, student_id, relationship,
                     is_primary_contact, status)
                values
                    (601, 501, 301, 'FATHER', true, 'ACTIVE'),
                    (602, 501, 303, 'FATHER', true, 'ACTIVE'),
                    (603, 502, 301, 'MOTHER', false, 'ACTIVE'),
                    (604, 503, 301, 'GUARDIAN', false, 'ACTIVE'),
                    (605, 501, 304, 'FATHER', true, 'ACTIVE')
                """);
        entityManager.clear();
    }

    @Test
    void findsOnlyActiveStudentAccountsInSelectedClassAndYear() {
        var result = repository.findActiveStudentAccounts(10L, 1L);

        assertThat(result)
                .extracting(Account::getId)
                .containsExactly(101L, 103L);
    }

    @Test
    void findsDistinctActiveParentAccountsForActiveStudents() {
        var result = repository.findActiveParentAccounts(10L, 1L);

        assertThat(result)
                .extracting(Account::getId)
                .containsExactly(201L);
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
