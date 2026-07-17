package com.myfschool.academic;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class TimetableRepositoryTests {

    @Autowired
    private TimetableRepository timetableRepository;

    @Autowired
    private EntityManager entityManager;

    @Test
    void findsCommonAndSelectedGroupEntriesEffectiveDuringRequestedWeek() {
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
                    (1, 1, 'Học kỳ 1', 1, '2026-08-01', '2026-12-31', 'ACTIVE')
                """);
        executeUpdate("""
                insert into class (id, academic_year_id, class_code, class_name)
                values (1, 1, '10A1', '10A1')
                """);
        executeUpdate("""
                insert into subject (id, subject_code, subject_name)
                values (1, 'TOAN', 'Toán')
                """);
        executeUpdate("""
                insert into account
                    (id, username, password_hash, status, created_at, updated_at)
                values
                    (1, 'teacher_test', 'test-password-hash', 'ACTIVE',
                     current_timestamp, current_timestamp)
                """);
        executeUpdate("""
                insert into teacher (id, account_id, teacher_code, full_name, status)
                values (1, 1, 'TCH001', 'Giáo viên Toán', 'ACTIVE')
                """);
        executeUpdate("""
                insert into lesson_slot
                    (id, shift, slot_index, start_time, end_time)
                values
                    (1, 'MORNING', 2, '08:25:00', '09:10:00')
                """);
        executeUpdate("""
                insert into study_group
                    (id, class_id, subject_cluster_id, group_code, group_name, status)
                values
                    (10, 1, 100, '10A1-TN', '10A1 - Cụm Tự nhiên', 'ACTIVE'),
                    (11, 1, 101, '10A1-XH', '10A1 - Cụm Xã hội', 'ACTIVE')
                """);
        executeUpdate("""
                insert into timetable
                    (id, semester_id, class_id, study_group_id, subject_id, teacher_id,
                     lesson_slot_id, day_of_week, slot_index, start_time,
                     end_time, room, effective_from, effective_to, status)
                values
                    (1, 1, 1, null, 1, 1, 1, 1, 2, '08:25:00', '09:10:00',
                     'A101', '2026-08-01', '2026-12-31', 'PUBLISHED'),
                    (2, 1, 1, null, 1, 1, 1, 2, 2, '08:25:00', '09:10:00',
                     'A101', '2026-08-01', '2026-12-31', 'DRAFT'),
                    (3, 1, 1, null, 1, 1, 1, 4, 2, '08:25:00', '09:10:00',
                     'A101', '2026-09-01', '2026-12-31', 'PUBLISHED'),
                    (4, 1, 1, 10, 1, 1, 1, 2, 2, '08:25:00', '09:10:00',
                     'A102', '2026-08-01', '2026-12-31', 'PUBLISHED'),
                    (5, 1, 1, 11, 1, 1, 1, 3, 2, '08:25:00', '09:10:00',
                     'A103', '2026-08-01', '2026-12-31', 'PUBLISHED')
                """);
        entityManager.clear();

        var result = timetableRepository.findClassTimetableForWeek(
                1L,
                1L,
                10L,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        );

        assertThat(result).extracting(Timetable::getId).containsExactly(1L, 4L);
        assertThat(result.getFirst()).satisfies(entry -> {
            assertThat(entry.getSchoolClass().getClassCode()).isEqualTo("10A1");
            assertThat(entry.getSubject().getSubjectName()).isEqualTo("Toán");
            assertThat(entry.getTeacher().getFullName()).isEqualTo("Giáo viên Toán");
            assertThat(entry.getLessonSlot().getShift()).isEqualTo(LessonShift.MORNING);
            assertThat(entry.getStudyGroup()).isNull();
        });
        assertThat(result.get(1).getStudyGroup().getGroupCode()).isEqualTo("10A1-TN");

        var commonOnly = timetableRepository.findClassTimetableForWeek(
                1L,
                1L,
                null,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        );

        assertThat(commonOnly).extracting(Timetable::getId).containsExactly(1L);

        var teacherTimetable = timetableRepository.findTeacherTimetableForWeek(
                1L,
                1L,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        );

        assertThat(teacherTimetable)
                .extracting(Timetable::getId)
                .containsExactly(1L, 4L, 5L);
        assertThat(teacherTimetable.get(1)).satisfies(entry -> {
            assertThat(entry.getSchoolClass().getClassCode()).isEqualTo("10A1");
            assertThat(entry.getStudyGroup().getGroupCode()).isEqualTo("10A1-TN");
            assertThat(entry.getSubject().getSubjectCode()).isEqualTo("TOAN");
            assertThat(entry.getTeacher().getTeacherCode()).isEqualTo("TCH001");
        });

        var allHomeroomEntries = timetableRepository
                .findHomeroomClassTimetableForWeek(
                        1L,
                        1L,
                        null,
                        TimetableStatus.PUBLISHED,
                        LocalDate.of(2026, 8, 3),
                        LocalDate.of(2026, 8, 9)
                );
        assertThat(allHomeroomEntries)
                .extracting(Timetable::getId)
                .containsExactly(1L, 4L, 5L);

        var selectedHomeroomGroup = timetableRepository
                .findHomeroomClassTimetableForWeek(
                        1L,
                        1L,
                        10L,
                        TimetableStatus.PUBLISHED,
                        LocalDate.of(2026, 8, 3),
                        LocalDate.of(2026, 8, 9)
                );
        assertThat(selectedHomeroomGroup)
                .extracting(Timetable::getId)
                .containsExactly(1L, 4L);
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
