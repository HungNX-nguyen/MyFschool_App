package com.myfschool.schoolevent;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class SchoolEventRepositoryTests {

    private static final LocalDate CURRENT_DATE = LocalDate.of(2026, 8, 10);
    private static final LocalTime CURRENT_TIME = LocalTime.of(12, 0);

    @Autowired
    private SchoolEventRepository schoolEventRepository;

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
                insert into account
                    (id, username, password_hash, status, created_at, updated_at)
                values
                    (1, 'admin-event-test', 'hash', 'ACTIVE',
                     current_timestamp, current_timestamp),
                    (2, 'teacher-event-test', 'hash', 'ACTIVE',
                     current_timestamp, current_timestamp)
                """);
        executeUpdate("""
                insert into class
                    (id, academic_year_id, class_code, class_name)
                values
                    (10, 1, '10A1', 'Lớp 10A1'),
                    (11, 1, '10A2', 'Lớp 10A2')
                """);
        executeUpdate("""
                insert into school_event
                    (id, title, description, scope, class_id, event_date,
                     start_time, end_time, is_all_day, location,
                     participation_type, status, created_by_account_id,
                     published_at, created_at, updated_at)
                values
                    (101, 'Sự kiện toàn trường sắp tới', 'School upcoming',
                     'SCHOOL', null, '2026-08-12', null, null, 1, 'Sân trường',
                     'REQUIRED', 'PUBLISHED', 1, current_timestamp,
                     current_timestamp, current_timestamp),
                    (102, 'Sự kiện lớp 10A1 sắp tới', 'Class upcoming',
                     'CLASS', 10, '2026-08-11', '09:00:00', '10:00:00', 0, 'A101',
                     'OPTIONAL', 'PUBLISHED', 2, current_timestamp,
                     current_timestamp, current_timestamp),
                    (103, 'Sự kiện lớp khác', 'Other class',
                     'CLASS', 11, '2026-08-11', '08:00:00', '09:00:00', 0, 'A102',
                     'REQUIRED', 'PUBLISHED', 2, current_timestamp,
                     current_timestamp, current_timestamp),
                    (104, 'Bản nháp lớp 10A1', 'Draft',
                     'CLASS', 10, '2026-08-11', '13:00:00', '14:00:00', 0, 'A101',
                     'REQUIRED', 'DRAFT', 2, null,
                     current_timestamp, current_timestamp),
                    (105, 'Sự kiện đã kết thúc hôm nay', 'Past today',
                     'CLASS', 10, '2026-08-10', '08:00:00', '09:00:00', 0, 'A101',
                     'REQUIRED', 'PUBLISHED', 2, current_timestamp,
                     current_timestamp, current_timestamp),
                    (106, 'Sự kiện toàn trường đã qua', 'School past',
                     'SCHOOL', null, '2026-08-09', null, null, 1, 'Sân trường',
                     'OPTIONAL', 'PUBLISHED', 1, current_timestamp,
                     current_timestamp, current_timestamp),
                    (107, 'Sự kiện đang diễn ra', 'Ongoing',
                     'CLASS', 10, '2026-08-10', '11:00:00', '13:00:00', 0, 'A101',
                     'REQUIRED', 'PUBLISHED', 2, current_timestamp,
                     current_timestamp, current_timestamp),
                    (108, 'Sự kiện đã hủy', 'Cancelled',
                     'SCHOOL', null, '2026-08-13', null, null, 1, 'Sân trường',
                     'OPTIONAL', 'CANCELLED', 1, current_timestamp,
                     current_timestamp, current_timestamp)
                """);
        entityManager.clear();
    }

    @Test
    void loadsOnlyPublishedSchoolAndCurrentClassUpcomingEvents() {
        var events = schoolEventRepository.findUpcomingVisibleEvents(
                10L,
                null,
                CURRENT_DATE,
                CURRENT_TIME
        );

        assertThat(events)
                .extracting(SchoolEvent::getId)
                .containsExactly(107L, 102L, 101L);
    }

    @Test
    void separatesPastEventsAndSupportsScopeFilter() {
        var pastEvents = schoolEventRepository.findPastVisibleEvents(
                10L,
                null,
                CURRENT_DATE,
                CURRENT_TIME
        );
        var classEvents = schoolEventRepository.findUpcomingVisibleEvents(
                10L,
                SchoolEventScope.CLASS,
                CURRENT_DATE,
                CURRENT_TIME
        );
        var schoolEvents = schoolEventRepository.findUpcomingVisibleEvents(
                10L,
                SchoolEventScope.SCHOOL,
                CURRENT_DATE,
                CURRENT_TIME
        );

        assertThat(pastEvents)
                .extracting(SchoolEvent::getId)
                .containsExactly(105L, 106L);
        assertThat(classEvents)
                .extracting(SchoolEvent::getId)
                .containsExactly(107L, 102L);
        assertThat(schoolEvents)
                .extracting(SchoolEvent::getId)
                .containsExactly(101L);
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
