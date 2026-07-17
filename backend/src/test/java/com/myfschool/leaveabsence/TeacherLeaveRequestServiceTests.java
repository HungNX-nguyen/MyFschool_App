package com.myfschool.leaveabsence;

import com.myfschool.academic.AcademicYearRepository;
import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.leaveabsence.dto.ReviewLeaveRequestRequest;
import com.myfschool.parent.Parent;
import com.myfschool.student.Student;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;
import java.util.stream.StreamSupport;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TeacherLeaveRequestServiceTests {

    @Mock
    private TeacherRepository teacherRepository;

    @Mock
    private AcademicYearRepository academicYearRepository;

    @Mock
    private SchoolClassRepository schoolClassRepository;

    @Mock
    private LeaveRequestRepository leaveRequestRepository;

    @Mock
    private AbsenceRecordRepository absenceRecordRepository;

    @Mock
    private LeaveRequestMapper leaveRequestMapper;

    private TeacherLeaveRequestService service;

    @BeforeEach
    void setUp() {
        service = new TeacherLeaveRequestService(
                teacherRepository,
                academicYearRepository,
                schoolClassRepository,
                leaveRequestRepository,
                absenceRecordRepository,
                leaveRequestMapper
        );
    }

    @Test
    void approvesRequestAndCreatesExcusedAbsenceForEveryInclusiveDate() {
        var teacher = mock(Teacher.class);
        var schoolClass = mock(SchoolClass.class);
        var student = mock(Student.class);
        var parent = mock(Parent.class);
        var response = response();
        var leaveRequest = new LeaveRequest(
                student,
                parent,
                schoolClass,
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 12),
                "Nghỉ ốm"
        );

        when(teacher.getId()).thenReturn(20L);
        when(schoolClass.getHomeroomTeacher()).thenReturn(teacher);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(leaveRequestRepository.findDetailedById(100L))
                .thenReturn(Optional.of(leaveRequest));
        when(leaveRequestMapper.toResponse(leaveRequest)).thenReturn(response);

        var result = service.reviewLeaveRequest(
                10L,
                100L,
                new ReviewLeaveRequestRequest(
                        LeaveRequestStatus.APPROVED,
                        "Đồng ý"
                )
        );

        assertThat(result).isSameAs(response);
        assertThat(leaveRequest.getStatus()).isEqualTo(LeaveRequestStatus.APPROVED);
        assertThat(leaveRequest.getReviewedByTeacher()).isSameAs(teacher);
        assertThat(leaveRequest.getReviewedAt()).isNotNull();

        @SuppressWarnings({"unchecked", "rawtypes"})
        ArgumentCaptor<Iterable<AbsenceRecord>> captor = (ArgumentCaptor) ArgumentCaptor
                .forClass(Iterable.class);
        verify(absenceRecordRepository).saveAll(captor.capture());
        var records = StreamSupport.stream(captor.getValue().spliterator(), false).toList();

        assertThat(records).extracting(AbsenceRecord::getAbsenceDate).containsExactly(
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 11),
                LocalDate.of(2026, 8, 12)
        );
        assertThat(records).allSatisfy(record -> {
            assertThat(record.getStatus()).isEqualTo(AbsenceStatus.EXCUSED_ABSENT);
            assertThat(record.getSource()).isEqualTo(AbsenceSource.LEAVE_REQUEST);
            assertThat(record.getLeaveRequest()).isSameAs(leaveRequest);
            assertThat(record.getRecordedByTeacher()).isSameAs(teacher);
        });
    }

    @Test
    void rejectsRejectedDecisionWithoutReviewNote() {
        assertThatThrownBy(() -> service.reviewLeaveRequest(
                10L,
                100L,
                new ReviewLeaveRequestRequest(LeaveRequestStatus.REJECTED, "  ")
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.VALIDATION_ERROR));

        verify(teacherRepository, never()).findByAccountIdAndStatus(any(), any());
        verify(absenceRecordRepository, never()).saveAll(any());
    }

    @Test
    void rejectsRequestWithoutCreatingAbsenceRecords() {
        var teacher = mock(Teacher.class);
        var schoolClass = mock(SchoolClass.class);
        var leaveRequest = new LeaveRequest(
                mock(Student.class),
                mock(Parent.class),
                schoolClass,
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 10),
                "Nghỉ ốm"
        );

        when(teacher.getId()).thenReturn(20L);
        when(schoolClass.getHomeroomTeacher()).thenReturn(teacher);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(leaveRequestRepository.findDetailedById(100L))
                .thenReturn(Optional.of(leaveRequest));

        service.reviewLeaveRequest(
                10L,
                100L,
                new ReviewLeaveRequestRequest(
                        LeaveRequestStatus.REJECTED,
                        "Thông tin chưa hợp lệ"
                )
        );

        assertThat(leaveRequest.getStatus()).isEqualTo(LeaveRequestStatus.REJECTED);
        assertThat(leaveRequest.getReviewNote()).isEqualTo("Thông tin chưa hợp lệ");
        verify(absenceRecordRepository, never()).saveAll(any());
    }

    @Test
    void rejectsTeacherWhoIsNotHomeroomTeacherOfRequestClass() {
        var teacher = mock(Teacher.class);
        var anotherTeacher = mock(Teacher.class);
        var schoolClass = mock(SchoolClass.class);
        var leaveRequest = new LeaveRequest(
                mock(Student.class),
                mock(Parent.class),
                schoolClass,
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 10),
                "Nghỉ ốm"
        );

        when(teacher.getId()).thenReturn(20L);
        when(anotherTeacher.getId()).thenReturn(21L);
        when(schoolClass.getHomeroomTeacher()).thenReturn(anotherTeacher);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(leaveRequestRepository.findDetailedById(100L))
                .thenReturn(Optional.of(leaveRequest));

        assertThatThrownBy(() -> service.reviewLeaveRequest(
                10L,
                100L,
                new ReviewLeaveRequestRequest(LeaveRequestStatus.APPROVED, null)
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verify(absenceRecordRepository, never()).saveAll(any());
    }

    private LeaveRequestResponse response() {
        return new LeaveRequestResponse(
                100L,
                30L,
                "STU0030",
                "Học sinh Test",
                20L,
                "Phụ huynh Test",
                40L,
                "10A1",
                "Lớp 10A1",
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 12),
                "Nghỉ ốm",
                LeaveRequestStatus.APPROVED,
                50L,
                "Giáo viên Test",
                null,
                "Đồng ý",
                null
        );
    }
}
