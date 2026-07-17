package com.myfschool.schoolevent;

import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.notification.NotificationCreator;
import com.myfschool.notification.NotificationRecipientResolver;
import com.myfschool.notification.NotificationRecipientType;
import com.myfschool.notification.NotificationType;
import com.myfschool.schoolevent.dto.ClassEventCreationResponse;
import com.myfschool.schoolevent.dto.CreateClassEventRequest;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class TeacherClassEventService {

    private static final String RELATED_ENTITY_TYPE = "SCHOOL_EVENT";
    private static final String DEFAULT_EVENT_NOTIFICATION_CONTENT =
            "Sự kiện lớp mới đã được phát hành.";

    private final TeacherRepository teacherRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SchoolEventRepository schoolEventRepository;
    private final NotificationRecipientResolver recipientResolver;
    private final NotificationCreator notificationCreator;

    public TeacherClassEventService(
            TeacherRepository teacherRepository,
            SchoolClassRepository schoolClassRepository,
            SchoolEventRepository schoolEventRepository,
            NotificationRecipientResolver recipientResolver,
            NotificationCreator notificationCreator
    ) {
        this.teacherRepository = teacherRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.schoolEventRepository = schoolEventRepository;
        this.recipientResolver = recipientResolver;
        this.notificationCreator = notificationCreator;
    }

    @Transactional
    public ClassEventCreationResponse createClassEvent(
            Long accountId,
            Long classId,
            CreateClassEventRequest request
    ) {
        validateTime(request);
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
                    "Chỉ có thể tạo sự kiện cho lớp thuộc năm học đang hoạt động"
            );
        }

        var event = SchoolEvent.createClassEvent(
                request.title().trim(),
                normalize(request.description()),
                schoolClass,
                request.eventDate(),
                request.startTime(),
                request.endTime(),
                request.allDay(),
                normalize(request.location()),
                request.participationType(),
                teacher.getAccount()
        );
        if (request.publishNow()) {
            event.publish(LocalDateTime.now());
        }
        var savedEvent = schoolEventRepository.save(event);

        if (request.publishNow()) {
            var recipientAccounts = recipientResolver.resolve(
                    schoolClass.getId(),
                    academicYear.getId(),
                    NotificationRecipientType.PARENT_AND_STUDENT
            );
            notificationCreator.createForEntity(
                    savedEvent.getTitle(),
                    savedEvent.getDescription() == null
                            ? DEFAULT_EVENT_NOTIFICATION_CONTENT
                            : savedEvent.getDescription(),
                    NotificationType.EVENT,
                    RELATED_ENTITY_TYPE,
                    savedEvent.getId(),
                    teacher.getAccount(),
                    recipientAccounts
            );
        }

        return new ClassEventCreationResponse(
                savedEvent.getId(),
                savedEvent.getStatus(),
                savedEvent.getPublishedAt()
        );
    }

    private void validateTime(CreateClassEventRequest request) {
        if (request.allDay() == null || request.publishNow() == null) {
            throw validationError("Thông tin thời gian hoặc phát hành không hợp lệ");
        }
        if (request.allDay()) {
            if (request.startTime() != null || request.endTime() != null) {
                throw validationError("Sự kiện cả ngày không được có giờ bắt đầu hoặc kết thúc");
            }
            return;
        }
        if (request.startTime() == null) {
            throw validationError("Giờ bắt đầu là bắt buộc với sự kiện không diễn ra cả ngày");
        }
        if (request.endTime() != null
                && !request.endTime().isAfter(request.startTime())) {
            throw validationError("Giờ kết thúc phải sau giờ bắt đầu");
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private BusinessException validationError(String message) {
        return new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                HttpStatus.BAD_REQUEST,
                message
        );
    }
}
