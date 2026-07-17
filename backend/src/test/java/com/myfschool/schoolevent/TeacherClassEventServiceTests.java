package com.myfschool.schoolevent;

import com.myfschool.academic.AcademicYear;
import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.account.Account;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.notification.NotificationCreator;
import com.myfschool.notification.NotificationRecipientResolver;
import com.myfschool.notification.NotificationRecipientType;
import com.myfschool.notification.NotificationType;
import com.myfschool.schoolevent.dto.CreateClassEventRequest;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TeacherClassEventServiceTests {

    @Mock
    private TeacherRepository teacherRepository;

    @Mock
    private SchoolClassRepository schoolClassRepository;

    @Mock
    private SchoolEventRepository schoolEventRepository;

    @Mock
    private NotificationRecipientResolver recipientResolver;

    @Mock
    private NotificationCreator notificationCreator;

    @InjectMocks
    private TeacherClassEventService service;

    @Test
    void savesDraftWithoutCreatingNotification() {
        var creator = mock(Account.class);
        var teacher = teacher(20L);
        when(teacher.getAccount()).thenReturn(creator);
        var academicYear = academicYear(AcademicYearStatus.ACTIVE);
        var schoolClass = schoolClass(academicYear);
        stubHomeroomClass(teacher, schoolClass);
        when(schoolEventRepository.save(any(SchoolEvent.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        var result = service.createClassEvent(10L, 30L, request(false));

        var captor = ArgumentCaptor.forClass(SchoolEvent.class);
        verify(schoolEventRepository).save(captor.capture());
        var event = captor.getValue();
        assertThat(event.getScope()).isEqualTo(SchoolEventScope.CLASS);
        assertThat(event.getStatus()).isEqualTo(SchoolEventStatus.DRAFT);
        assertThat(event.getPublishedAt()).isNull();
        assertThat(event.getCreatedByAccount()).isSameAs(creator);
        assertThat(result.status()).isEqualTo(SchoolEventStatus.DRAFT);
        verifyNoInteractions(recipientResolver, notificationCreator);
    }

    @Test
    void publishesEventAndCreatesEventNotificationInClassScope() {
        var creator = mock(Account.class);
        var recipient = mock(Account.class);
        var teacher = teacher(20L);
        when(teacher.getAccount()).thenReturn(creator);
        var academicYear = academicYear(AcademicYearStatus.ACTIVE);
        when(academicYear.getId()).thenReturn(1L);
        var schoolClass = schoolClass(academicYear);
        when(schoolClass.getId()).thenReturn(30L);
        stubHomeroomClass(teacher, schoolClass);
        when(schoolEventRepository.save(any(SchoolEvent.class)))
                .thenAnswer(invocation -> {
                    SchoolEvent event = invocation.getArgument(0);
                    ReflectionTestUtils.setField(event, "id", 50L);
                    return event;
                });
        when(recipientResolver.resolve(
                30L,
                1L,
                NotificationRecipientType.PARENT_AND_STUDENT
        )).thenReturn(List.of(recipient));

        var result = service.createClassEvent(10L, 30L, request(true));

        assertThat(result.eventId()).isEqualTo(50L);
        assertThat(result.status()).isEqualTo(SchoolEventStatus.PUBLISHED);
        assertThat(result.publishedAt()).isNotNull();
        verify(notificationCreator).createForEntity(
                "Họp phụ huynh",
                "Họp tại lớp 10A1.",
                NotificationType.EVENT,
                "SCHOOL_EVENT",
                50L,
                creator,
                List.of(recipient)
        );
    }

    @Test
    void rejectsInvalidTimeRangeBeforeAccessingDatabase() {
        var invalidRequest = new CreateClassEventRequest(
                "Sự kiện",
                null,
                LocalDate.of(2026, 8, 15),
                false,
                LocalTime.of(10, 0),
                LocalTime.of(9, 0),
                null,
                SchoolEventParticipationType.REQUIRED,
                false
        );

        assertThatThrownBy(() -> service.createClassEvent(10L, 30L, invalidRequest))
                .isInstanceOf(BusinessException.class);

        verifyNoInteractions(
                teacherRepository,
                schoolClassRepository,
                schoolEventRepository,
                recipientResolver,
                notificationCreator
        );
    }

    @Test
    void rejectsClassNotAssignedToTeacher() {
        var teacher = teacher(20L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(30L, 20L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.createClassEvent(10L, 30L, request(false)))
                .isInstanceOf(BusinessException.class);

        verify(schoolEventRepository, never()).save(any());
        verifyNoInteractions(recipientResolver, notificationCreator);
    }

    @Test
    void rejectsClassFromClosedAcademicYear() {
        var teacher = teacher(20L);
        var schoolClass = schoolClass(academicYear(AcademicYearStatus.CLOSED));
        stubHomeroomClass(teacher, schoolClass);

        assertThatThrownBy(() -> service.createClassEvent(10L, 30L, request(false)))
                .isInstanceOf(BusinessException.class);

        verify(schoolEventRepository, never()).save(any());
        verifyNoInteractions(recipientResolver, notificationCreator);
    }

    private void stubHomeroomClass(Teacher teacher, SchoolClass schoolClass) {
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(30L, 20L))
                .thenReturn(Optional.of(schoolClass));
    }

    private CreateClassEventRequest request(boolean publishNow) {
        return new CreateClassEventRequest(
                "  Họp phụ huynh  ",
                "  Họp tại lớp 10A1.  ",
                LocalDate.of(2026, 8, 15),
                false,
                LocalTime.of(8, 0),
                LocalTime.of(10, 0),
                "  Phòng A101  ",
                SchoolEventParticipationType.REQUIRED,
                publishNow
        );
    }

    private Teacher teacher(Long id) {
        var teacher = mock(Teacher.class);
        when(teacher.getId()).thenReturn(id);
        return teacher;
    }

    private AcademicYear academicYear(AcademicYearStatus status) {
        var academicYear = mock(AcademicYear.class);
        when(academicYear.getStatus()).thenReturn(status);
        return academicYear;
    }

    private SchoolClass schoolClass(AcademicYear academicYear) {
        var schoolClass = mock(SchoolClass.class);
        when(schoolClass.getAcademicYear()).thenReturn(academicYear);
        return schoolClass;
    }
}
