package com.myfschool.student;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class StudentClassHistoryRepositoryTests {

    @Autowired
    private StudentClassHistoryRepository repository;

    @Autowired
    private EntityManager entityManager;

    @Test
    void findsOnlyActiveStudentsWithActiveClassHistory() {
        executeUpdate("""
                insert into academic_year
                    (id, name, start_date, end_date, status)
                values
                    (1, '2026-2027', '2026-08-01', '2027-05-31', 'ACTIVE')
                """);
        executeUpdate("""
                insert into class (id, academic_year_id, class_code, class_name)
                values (10, 1, '10A1', 'Lớp 10A1')
                """);
        executeUpdate("""
                insert into student
                    (id, student_code, full_name, current_class_id, status)
                values
                    (1, 'STU001', 'An Nguyễn', 10, 'ACTIVE'),
                    (2, 'STU002', 'Bình Trần', 10, 'INACTIVE'),
                    (3, 'STU003', 'Chi Lê', null, 'ACTIVE')
                """);
        executeUpdate("""
                insert into student_class_history
                    (id, student_id, class_id, academic_year_id,
                     start_date, end_date, status, note)
                values
                    (1, 1, 10, 1, '2026-08-01', null, 'ACTIVE', null),
                    (2, 2, 10, 1, '2026-08-01', null, 'ACTIVE', null),
                    (3, 3, 10, 1, '2026-08-01', '2026-09-01',
                     'TRANSFERRED', null)
                """);
        entityManager.clear();

        var result = repository.findActiveStudentsForClassAndYear(
                10L,
                1L,
                StudentClassHistoryStatus.ACTIVE,
                StudentStatus.ACTIVE
        );

        assertThat(result).singleElement().satisfies(student -> {
            assertThat(student.getStudentCode()).isEqualTo("STU001");
            assertThat(student.getFullName()).isEqualTo("An Nguyễn");
        });
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
