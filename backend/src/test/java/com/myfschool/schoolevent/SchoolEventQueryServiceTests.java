package com.myfschool.schoolevent;

import com.myfschool.academic.SchoolClass;
import com.myfschool.account.RoleType;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.parent.Parent;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStatus;
import com.myfschool.parent.ParentStudent;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import com.myfschool.notification.NotificationRecipientRepository;
import com.myfschool.schoolevent.dto.SchoolEventListResponse;
import com.myfschool.schoolevent.dto.SchoolEventItemResponse;
import com.myfschool.student.Student;
import com.myfschool.student.StudentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SchoolEventQueryServiceTests {

    @Mock
    private SchoolEventRepository schoolEventRepository;

    @Mock
    private SchoolEventMapper schoolEventMapper;

    @Mock
    private ParentRepository parentRepository;

    @Mock
    private ParentStudentRepository parentStudentRepository;

    @Mock
    private StudentRepository studentRepository;

    @Mock
    private NotificationRecipientRepository notificationRecipientRepository;

    private SchoolEventQueryService service;

    @BeforeEach
    void setUp() {
        service = new SchoolEventQueryService(
                schoolEventRepository,
                schoolEventMapper,
                parentRepository,
                parentStudentRepository,
                studentRepository,
                notificationRecipientRepository
        );
    }

    @Test
    void parentDefaultsToUpcomingAllForLinkedStudentsCurrentClass() {
        var parent = mock(Parent.class);
        var link = mock(ParentStudent.class);
        var student = mock(Student.class);
        var schoolClass = mock(SchoolClass.class);
        var event = mock(SchoolEvent.class);
        var response = response(
                SchoolEventTimeRange.UPCOMING,
                SchoolEventViewScope.ALL
        );

        when(parent.getId()).thenReturn(20L);
        when(link.getStudent()).thenReturn(student);
        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(schoolClass.getId()).thenReturn(40L);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudent(
                20L,
                30L,
                ParentStudentStatus.ACTIVE
        )).thenReturn(Optional.of(link));
        when(schoolEventRepository.findUpcomingVisibleEvents(
                org.mockito.ArgumentMatchers.eq(40L),
                isNull(),
                any(LocalDate.class),
                any(LocalTime.class)
        )).thenReturn(List.of(event));
        when(schoolEventMapper.toListResponse(
                student,
                SchoolEventTimeRange.UPCOMING,
                SchoolEventViewScope.ALL,
                List.of(event)
        )).thenReturn(response);

        var result = service.getParentStudentEvents(10L, 30L, null, null);

        assertThat(result).isSameAs(response);
        verify(schoolEventRepository).findUpcomingVisibleEvents(
                org.mockito.ArgumentMatchers.eq(40L),
                isNull(),
                any(LocalDate.class),
                any(LocalTime.class)
        );
    }

    @Test
    void parentCannotViewEventsOfAnUnlinkedStudent() {
        var parent = mock(Parent.class);

        when(parent.getId()).thenReturn(20L);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudent(
                20L,
                31L,
                ParentStudentStatus.ACTIVE
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getParentStudentEvents(
                10L,
                31L,
                SchoolEventTimeRange.UPCOMING,
                SchoolEventViewScope.ALL
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verify(schoolEventRepository, never()).findUpcomingVisibleEvents(
                any(),
                any(),
                any(),
                any()
        );
    }

    @Test
    void studentCanRequestPastSchoolEvents() {
        var student = mock(Student.class);
        var schoolClass = mock(SchoolClass.class);
        var event = mock(SchoolEvent.class);
        var response = response(
                SchoolEventTimeRange.PAST,
                SchoolEventViewScope.SCHOOL
        );

        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(schoolClass.getId()).thenReturn(40L);
        when(studentRepository.findByAccountIdWithCurrentClass(10L))
                .thenReturn(Optional.of(student));
        when(schoolEventRepository.findPastVisibleEvents(
                org.mockito.ArgumentMatchers.eq(40L),
                org.mockito.ArgumentMatchers.eq(SchoolEventScope.SCHOOL),
                any(LocalDate.class),
                any(LocalTime.class)
        )).thenReturn(List.of(event));
        when(schoolEventMapper.toListResponse(
                student,
                SchoolEventTimeRange.PAST,
                SchoolEventViewScope.SCHOOL,
                List.of(event)
        )).thenReturn(response);

        var result = service.getStudentEvents(
                10L,
                SchoolEventTimeRange.PAST,
                SchoolEventViewScope.SCHOOL
        );

        assertThat(result).isSameAs(response);
        verify(schoolEventRepository).findPastVisibleEvents(
                org.mockito.ArgumentMatchers.eq(40L),
                org.mockito.ArgumentMatchers.eq(SchoolEventScope.SCHOOL),
                any(LocalDate.class),
                any(LocalTime.class)
        );
    }

    @Test
    void formerRecipientCanOpenNonDraftEventFromNotificationHistory() {
        var event = mock(SchoolEvent.class);
        var item = new SchoolEventItemResponse(
                50L,
                "Sự kiện lớp",
                "Nội dung",
                SchoolEventScope.CLASS,
                40L,
                "10A1",
                LocalDate.of(2026, 8, 20),
                LocalTime.of(8, 0),
                LocalTime.of(9, 0),
                false,
                "Phòng A101",
                SchoolEventParticipationType.REQUIRED
        );

        when(schoolEventRepository.findAccessibleDetail(50L))
                .thenReturn(Optional.of(event));
        when(studentRepository.findByAccountIdWithCurrentClass(10L))
                .thenReturn(Optional.empty());
        when(notificationRecipientRepository.existsSchoolEventRecipient(10L, 50L))
                .thenReturn(true);
        when(schoolEventMapper.toItemResponse(event)).thenReturn(item);

        assertThat(service.getAccessibleEvent(
                10L,
                RoleType.STUDENT,
                50L
        )).isSameAs(item);
    }

    @Test
    void unrelatedAccountCannotOpenEventByChangingId() {
        var event = mock(SchoolEvent.class);

        when(schoolEventRepository.findAccessibleDetail(50L))
                .thenReturn(Optional.of(event));
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getAccessibleEvent(
                10L,
                RoleType.PARENT,
                50L
        )).isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void teacherCannotUseParentStudentEventDetailEndpoint() {
        assertThatThrownBy(() -> service.getAccessibleEvent(
                10L,
                RoleType.TEACHER,
                50L
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verify(schoolEventRepository, never()).findAccessibleDetail(any());
    }

    private SchoolEventListResponse response(
            SchoolEventTimeRange timeRange,
            SchoolEventViewScope scope
    ) {
        return new SchoolEventListResponse(
                30L,
                40L,
                "10A1",
                timeRange,
                scope,
                List.of()
        );
    }
}
