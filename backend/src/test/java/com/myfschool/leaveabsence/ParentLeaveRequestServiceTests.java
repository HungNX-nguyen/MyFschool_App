package com.myfschool.leaveabsence;

import com.myfschool.academic.SchoolClass;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.leaveabsence.dto.CreateLeaveRequestRequest;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.parent.Parent;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStatus;
import com.myfschool.parent.ParentStudent;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import com.myfschool.student.Student;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ParentLeaveRequestServiceTests {

    @Mock
    private ParentRepository parentRepository;

    @Mock
    private ParentStudentRepository parentStudentRepository;

    @Mock
    private LeaveRequestRepository leaveRequestRepository;

    @Mock
    private LeaveRequestMapper leaveRequestMapper;

    private ParentLeaveRequestService service;

    @BeforeEach
    void setUp() {
        service = new ParentLeaveRequestService(
                parentRepository,
                parentStudentRepository,
                leaveRequestRepository,
                leaveRequestMapper
        );
    }

    @Test
    void createsPendingRequestUsingLinkedStudentAndCurrentClassSnapshot() {
        var parent = mock(Parent.class);
        var parentStudent = mock(ParentStudent.class);
        var student = mock(Student.class);
        var schoolClass = mock(SchoolClass.class);
        var response = response();

        when(parent.getId()).thenReturn(20L);
        when(student.getId()).thenReturn(30L);
        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(parentStudent.getStudent()).thenReturn(student);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudent(
                20L,
                30L,
                ParentStudentStatus.ACTIVE
        )).thenReturn(Optional.of(parentStudent));
        when(leaveRequestRepository.countOverlappingRequests(
                30L,
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 12),
                List.of(LeaveRequestStatus.PENDING, LeaveRequestStatus.APPROVED)
        )).thenReturn(0L);
        when(leaveRequestRepository.save(any(LeaveRequest.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(leaveRequestMapper.toResponse(any(LeaveRequest.class))).thenReturn(response);

        var result = service.createLeaveRequest(
                10L,
                30L,
                new CreateLeaveRequestRequest(
                        LocalDate.of(2026, 8, 10),
                        LocalDate.of(2026, 8, 12),
                        "  Nghỉ ốm  "
                )
        );

        assertThat(result).isSameAs(response);
        var captor = ArgumentCaptor.forClass(LeaveRequest.class);
        verify(leaveRequestRepository).save(captor.capture());
        assertThat(captor.getValue()).satisfies(request -> {
            assertThat(request.getStudent()).isSameAs(student);
            assertThat(request.getParent()).isSameAs(parent);
            assertThat(request.getSchoolClass()).isSameAs(schoolClass);
            assertThat(request.getReason()).isEqualTo("Nghỉ ốm");
            assertThat(request.getStatus()).isEqualTo(LeaveRequestStatus.PENDING);
        });
    }

    @Test
    void rejectsRequestWhenDateRangeOverlapsPendingOrApprovedRequest() {
        var parent = mock(Parent.class);
        var parentStudent = mock(ParentStudent.class);
        var student = mock(Student.class);
        var schoolClass = mock(SchoolClass.class);

        when(parent.getId()).thenReturn(20L);
        when(student.getId()).thenReturn(30L);
        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(parentStudent.getStudent()).thenReturn(student);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudent(
                20L,
                30L,
                ParentStudentStatus.ACTIVE
        )).thenReturn(Optional.of(parentStudent));
        when(leaveRequestRepository.countOverlappingRequests(
                30L,
                LocalDate.of(2026, 8, 10),
                LocalDate.of(2026, 8, 12),
                List.of(LeaveRequestStatus.PENDING, LeaveRequestStatus.APPROVED)
        )).thenReturn(1L);

        assertThatThrownBy(() -> service.createLeaveRequest(
                10L,
                30L,
                new CreateLeaveRequestRequest(
                        LocalDate.of(2026, 8, 10),
                        LocalDate.of(2026, 8, 12),
                        "Nghỉ ốm"
                )
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode())
                        .isEqualTo(ErrorCode.LEAVE_REQUEST_DATE_OVERLAP));

        verify(leaveRequestRepository, never()).save(any());
    }

    @Test
    void rejectsCancellationWhenRequestBelongsToAnotherParent() {
        var currentParent = mock(Parent.class);
        var ownerParent = mock(Parent.class);
        var leaveRequest = mock(LeaveRequest.class);

        when(currentParent.getId()).thenReturn(20L);
        when(ownerParent.getId()).thenReturn(21L);
        when(leaveRequest.getParent()).thenReturn(ownerParent);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(currentParent));
        when(leaveRequestRepository.findDetailedById(100L))
                .thenReturn(Optional.of(leaveRequest));

        assertThatThrownBy(() -> service.cancelLeaveRequest(10L, 100L))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verify(leaveRequest, never()).cancel();
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
                LeaveRequestStatus.PENDING,
                null,
                null,
                null,
                null,
                null
        );
    }
}
