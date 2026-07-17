package com.myfschool.notification;

import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.notification.dto.ClassNotificationResponse;
import com.myfschool.notification.dto.CreateClassNotificationRequest;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ClassNotificationService {

    private static final String RELATED_ENTITY_TYPE = "CLASS";

    private final TeacherRepository teacherRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final NotificationRecipientResolver recipientResolver;
    private final NotificationCreator notificationCreator;

    public ClassNotificationService(
            TeacherRepository teacherRepository,
            SchoolClassRepository schoolClassRepository,
            NotificationRecipientResolver recipientResolver,
            NotificationCreator notificationCreator
    ) {
        this.teacherRepository = teacherRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.recipientResolver = recipientResolver;
        this.notificationCreator = notificationCreator;
    }

    @Transactional
    public ClassNotificationResponse sendClassNotification(
            Long accountId,
            Long classId,
            CreateClassNotificationRequest request
    ) {
        var teacher = teacherRepository
                .findByAccountIdAndStatus(accountId, TeacherStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ giáo viên"));
        var schoolClass = schoolClassRepository
                .findHomeroomClass(classId, teacher.getId())
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.FORBIDDEN,
                        HttpStatus.FORBIDDEN,
                        "Bạn không phải giáo viên chủ nhiệm của lớp này"
                ));
        var academicYear = schoolClass.getAcademicYear();
        if (academicYear.getStatus() != AcademicYearStatus.ACTIVE) {
            throw new BusinessException(
                    ErrorCode.BUSINESS_RULE_VIOLATION,
                    HttpStatus.CONFLICT,
                    "Chỉ có thể gửi thông báo cho lớp thuộc năm học đang hoạt động"
            );
        }

        var recipientAccounts = recipientResolver.resolve(
                schoolClass.getId(),
                academicYear.getId(),
                request.recipientType()
        );
        var savedNotification = notificationCreator.createForEntity(
                request.title().trim(),
                request.content().trim(),
                NotificationType.ANNOUNCEMENT,
                RELATED_ENTITY_TYPE,
                schoolClass.getId(),
                teacher.getAccount(),
                recipientAccounts
        );
        return new ClassNotificationResponse(
                savedNotification.getId(),
                recipientAccounts.size(),
                savedNotification.getCreatedAt()
        );
    }
}
