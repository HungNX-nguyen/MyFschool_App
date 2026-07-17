package com.myfschool.parent;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class ParentStudentRepositoryTests {

    @Autowired
    private ParentStudentRepository parentStudentRepository;

    @Autowired
    private EntityManager entityManager;

    @Test
    void findsOnlyActiveLinksAndFetchesCurrentClass() {
        executeUpdate("""
                insert into account
                    (id, username, password_hash, status, created_at, updated_at)
                values
                    (101, 'parent-repository-test', 'hash', 'ACTIVE', current_timestamp, current_timestamp)
                """);
        executeUpdate("""
                insert into parent (id, account_id, full_name, status)
                values (201, 101, 'Parent Test', 'ACTIVE')
                """);
        executeUpdate("""
                insert into academic_year
                    (id, name, start_date, end_date, status)
                values
                    (1, '2026-2027', '2026-08-01', '2027-05-31', 'ACTIVE')
                """);
        executeUpdate("""
                insert into class (id, academic_year_id, class_code, class_name)
                values (301, 1, '10A1', '10A1')
                """);
        executeUpdate("""
                insert into student
                    (id, student_code, full_name, current_class_id, status)
                values
                    (401, 'STU0401', 'Active Student', 301, 'ACTIVE'),
                    (402, 'STU0402', 'Inactive Link Student', null, 'PENDING_CLASS_ASSIGNMENT')
                """);
        executeUpdate("""
                insert into parent_student
                    (id, parent_id, student_id, relationship, is_primary_contact, status)
                values
                    (501, 201, 401, 'FATHER', true, 'ACTIVE'),
                    (502, 201, 402, 'FATHER', false, 'INACTIVE')
                """);
        entityManager.clear();

        var result = parentStudentRepository.findLinkedStudents(
                201L,
                ParentStudentStatus.ACTIVE
        );

        assertThat(result).singleElement().satisfies(link -> {
            assertThat(link.getStudent().getStudentCode()).isEqualTo("STU0401");
            assertThat(link.getStudent().getCurrentClass()).isNotNull();
            assertThat(link.getStudent().getCurrentClass().getClassName()).isEqualTo("10A1");
            assertThat(link.getStudent().getCurrentClass().getAcademicYear().getName())
                    .isEqualTo("2026-2027");
            assertThat(link.isPrimaryContact()).isTrue();
        });
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
