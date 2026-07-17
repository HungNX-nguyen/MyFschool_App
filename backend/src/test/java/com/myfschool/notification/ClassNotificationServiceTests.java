package com.myfschool.notification;

import com.myfschool.academic.AcademicYear;
import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.account.Account;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.notification.dto.CreateClassNotificationRequest;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ClassNotificationServiceTests {

    @Mock
    private TeacherRepository teacherRepository;

    @Mock
    private SchoolClassRepository schoolClassRepository;

    @Mock
    private NotificationRecipientResolver recipientResolver;

    @Mock
    private NotificationCreator notificationCreator;

    @InjectMocks
    private ClassNotificationService service;

    @Test
    void createsAnnouncementAndRecipientsForActiveHomeroomClass() {
        var creator = mock(Account.class);
        var teacher = teacher(20L);
        when(teacher.getAccount()).thenReturn(creator);
        var academicYear = academicYear(AcademicYearStatus.ACTIVE);
        when(academicYear.getId()).thenReturn(1L);
        var schoolClass = schoolClass(academicYear);
        when(schoolClass.getId()).thenReturn(30L);
        var studentAccount = mock(Account.class);
        var parentAccount = mock(Account.class);
        var savedNotification = mock(Notification.class);
        when(savedNotification.getId()).thenReturn(100L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(30L, 20L))
                .thenReturn(Optional.of(schoolClass));
        when(recipientResolver.resolve(
                30L,
                1L,
                NotificationRecipientType.PARENT_AND_STUDENT
        )).thenReturn(List.of(studentAccount, parentAccount));
        when(notificationCreator.createForEntity(
                "Nhắc lịch kiểm tra",
                "Chuẩn bị bài ngày mai.",
                NotificationType.ANNOUNCEMENT,
                "CLASS",
                30L,
                creator,
                List.of(studentAccount, parentAccount)
        )).thenReturn(savedNotification);

        var result = service.sendClassNotification(
                10L,
                30L,
                new CreateClassNotificationRequest(
                        "  Nhắc lịch kiểm tra  ",
                        "  Chuẩn bị bài ngày mai.  ",
                        NotificationRecipientType.PARENT_AND_STUDENT
                )
        );

        verify(notificationCreator).createForEntity(
                "Nhắc lịch kiểm tra",
                "Chuẩn bị bài ngày mai.",
                NotificationType.ANNOUNCEMENT,
                "CLASS",
                30L,
                creator,
                List.of(studentAccount, parentAccount)
        );
        assertThat(result.notificationId()).isEqualTo(100L);
        assertThat(result.recipientCount()).isEqualTo(2);
    }

    @Test
    void rejectsClassNotAssignedToTeacher() {
        var teacher = teacher(20L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(30L, 20L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.sendClassNotification(
                10L,
                30L,
                request()
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getHttpStatus()).isEqualTo(HttpStatus.FORBIDDEN)
        );

        verifyNoInteractions(recipientResolver, notificationCreator);
    }

    @Test
    void rejectsHomeroomClassFromClosedAcademicYear() {
        var teacher = teacher(20L);
        var schoolClass = schoolClass(
                academicYear(AcademicYearStatus.CLOSED)
        );
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(30L, 20L))
                .thenReturn(Optional.of(schoolClass));

        assertThatThrownBy(() -> service.sendClassNotification(
                10L,
                30L,
                request()
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getHttpStatus()).isEqualTo(HttpStatus.CONFLICT)
        );

        verifyNoInteractions(recipientResolver, notificationCreator);
    }

    @Test
    void doesNotSaveNotificationWithoutRecipients() {
        var teacher = teacher(20L);
        var creator = mock(Account.class);
        when(teacher.getAccount()).thenReturn(creator);
        var academicYear = academicYear(AcademicYearStatus.ACTIVE);
        when(academicYear.getId()).thenReturn(1L);
        var schoolClass = schoolClass(academicYear);
        when(schoolClass.getId()).thenReturn(30L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(30L, 20L))
                .thenReturn(Optional.of(schoolClass));
        when(recipientResolver.resolve(
                30L,
                1L,
                NotificationRecipientType.PARENT_AND_STUDENT
        )).thenReturn(List.of());
        when(notificationCreator.createForEntity(
                "Thông báo lớp",
                "Nội dung thông báo",
                NotificationType.ANNOUNCEMENT,
                "CLASS",
                30L,
                creator,
                List.of()
        )).thenThrow(new BusinessException(
                com.myfschool.common.exception.ErrorCode.BUSINESS_RULE_VIOLATION,
                HttpStatus.CONFLICT,
                "Không có tài khoản nhận thông báo phù hợp"
        ));

        assertThatThrownBy(() -> service.sendClassNotification(
                10L,
                30L,
                request()
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getHttpStatus()).isEqualTo(HttpStatus.CONFLICT)
        );

        verify(notificationCreator).createForEntity(
                "Thông báo lớp",
                "Nội dung thông báo",
                NotificationType.ANNOUNCEMENT,
                "CLASS",
                30L,
                creator,
                List.of()
        );
    }

    private CreateClassNotificationRequest request() {
        return new CreateClassNotificationRequest(
                "Thông báo lớp",
                "Nội dung thông báo",
                NotificationRecipientType.PARENT_AND_STUDENT
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
