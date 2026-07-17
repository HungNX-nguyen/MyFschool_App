package com.myfschool.leaveabsence;

import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@ActiveProfiles("test")
@DataJpaTest(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class LeaveRequestRepositoryTests {

    @Autowired
    private LeaveRequestRepository leaveRequestRepository;

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
                    (1, 'parent-leave-test', 'hash', 'ACTIVE',
                     current_timestamp, current_timestamp),
                    (2, 'teacher-leave-test', 'hash', 'ACTIVE',
                     current_timestamp, current_timestamp)
                """);
        executeUpdate("""
                insert into parent (id, account_id, full_name, status)
                values (1, 1, 'Phụ huynh Test', 'ACTIVE')
                """);
        executeUpdate("""
                insert into teacher
                    (id, account_id, teacher_code, full_name, status)
                values (2, 2, 'TCH002', 'Giáo viên Test', 'ACTIVE')
                """);
        executeUpdate("""
                insert into class
                    (id, academic_year_id, class_code, class_name, homeroom_teacher_id)
                values (10, 1, '10A1', 'Lớp 10A1', 2)
                """);
        executeUpdate("""
                insert into student
                    (id, student_code, full_name, current_class_id, status)
                values (20, 'STU0020', 'Học sinh Test', 10, 'ACTIVE')
                """);
        executeUpdate("""
                insert into leave_request
                    (id, student_id, parent_id, class_id, from_date, to_date,
                     reason, status, created_at, updated_at)
                values
                    (101, 20, 1, 10, '2026-08-10', '2026-08-12',
                     'Nghỉ ốm', 'PENDING', '2026-07-10 08:00:00', '2026-07-10 08:00:00'),
                    (102, 20, 1, 10, '2026-08-20', '2026-08-21',
                     'Việc gia đình', 'APPROVED', '2026-07-11 08:00:00', '2026-07-11 08:00:00'),
                    (103, 20, 1, 10, '2026-08-11', '2026-08-13',
                     'Đã từ chối', 'REJECTED', '2026-07-12 08:00:00', '2026-07-12 08:00:00'),
                    (104, 20, 1, 10, '2026-08-20', '2026-08-22',
                     'Đã hủy', 'CANCELLED', '2026-07-13 08:00:00', '2026-07-13 08:00:00')
                """);
        entityManager.clear();
    }

    @Test
    void detectsInclusiveOverlapOnlyForPendingAndApprovedRequests() {
        var overlapCount = leaveRequestRepository.countOverlappingRequests(
                20L,
                LocalDate.of(2026, 8, 12),
                LocalDate.of(2026, 8, 20),
                List.of(LeaveRequestStatus.PENDING, LeaveRequestStatus.APPROVED)
        );

        assertThat(overlapCount).isEqualTo(2);

        var nonOverlapCount = leaveRequestRepository.countOverlappingRequests(
                20L,
                LocalDate.of(2026, 8, 14),
                LocalDate.of(2026, 8, 19),
                List.of(LeaveRequestStatus.PENDING, LeaveRequestStatus.APPROVED)
        );

        assertThat(nonOverlapCount).isZero();
    }

    @Test
    void loadsParentAndHomeroomListsWithDetailsAndStatusFilter() {
        var allForParent = leaveRequestRepository.findForParent(1L, 20L, null);

        assertThat(allForParent)
                .extracting(LeaveRequest::getId)
                .containsExactly(104L, 103L, 102L, 101L);
        assertThat(allForParent.getLast()).satisfies(request -> {
            assertThat(request.getStudent().getStudentCode()).isEqualTo("STU0020");
            assertThat(request.getParent().getFullName()).isEqualTo("Phụ huynh Test");
            assertThat(request.getSchoolClass().getClassCode()).isEqualTo("10A1");
        });

        var pendingForTeacher = leaveRequestRepository.findForHomeroomClass(
                10L,
                LeaveRequestStatus.PENDING
        );

        assertThat(pendingForTeacher)
                .singleElement()
                .extracting(LeaveRequest::getId)
                .isEqualTo(101L);
        assertThat(leaveRequestRepository.findDetailedById(102L))
                .get()
                .extracting(LeaveRequest::getStatus)
                .isEqualTo(LeaveRequestStatus.APPROVED);
    }

    private void executeUpdate(String sql) {
        entityManager.createNativeQuery(sql).executeUpdate();
    }
}
