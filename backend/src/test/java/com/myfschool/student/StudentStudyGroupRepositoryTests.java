package com.myfschool.student;

import com.myfschool.academic.StudyGroupStatus;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class StudentStudyGroupRepositoryTests {

    @Autowired
    private StudentStudyGroupRepository studentStudyGroupRepository;

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
                insert into semester
                    (id, academic_year_id, name, semester_index, start_date, end_date, status)
                values
                    (101, 1, 'Học kỳ 1', 1, '2026-08-01', '2026-12-31', 'ACTIVE')
                """);
        executeUpdate("""
                insert into class (id, academic_year_id, class_code, class_name)
                values (201, 1, '12A1', '12A1')
                """);
        executeUpdate("""
                insert into student
                    (id, student_code, full_name, current_class_id, status)
                values
                    (301, 'STU0301', 'Học sinh trong nhóm', 201, 'ACTIVE'),
                    (302, 'STU0302', 'Học sinh ngoài thời gian', 201, 'ACTIVE')
                """);
        executeUpdate("""
                insert into study_group
                    (id, class_id, subject_cluster_id, group_code, group_name, status)
                values
                    (401, 201, 501, '12A1-TN', '12A1 - Cụm Tự nhiên', 'ACTIVE')
                """);
        executeUpdate("""
                insert into student_study_group
                    (id, student_id, study_group_id, academic_year_id, semester_id,
                     effective_from, effective_to, status)
                values
                    (501, 301, 401, 1, 101, '2026-08-01', '2026-12-31', 'ACTIVE'),
                    (502, 302, 401, 1, 101, '2026-09-01', '2026-12-31', 'ACTIVE')
                """);
        entityManager.clear();
    }

    @Test
    void findsActiveStudyGroupOverlappingRequestedWeek() {
        var result = findActiveForAugustWeek(301L);

        assertThat(result).hasValueSatisfying(membership -> {
            assertThat(membership.getStudyGroup().getId()).isEqualTo(401L);
            assertThat(membership.getStudyGroup().getGroupCode()).isEqualTo("12A1-TN");
            assertThat(membership.getStudyGroup().getSchoolClass().getClassCode()).isEqualTo("12A1");
        });
    }

    @Test
    void returnsEmptyWhenMembershipDoesNotOverlapRequestedWeek() {
        assertThat(findActiveForAugustWeek(302L)).isEmpty();
    }

    private Optional<StudentStudyGroup> findActiveForAugustWeek(Long studentId) {
        return studentStudyGroupRepository.findActiveForWeek(
                studentId,
                101L,
                StudentStudyGroupStatus.ACTIVE,
                StudyGroupStatus.ACTIVE,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        );
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
