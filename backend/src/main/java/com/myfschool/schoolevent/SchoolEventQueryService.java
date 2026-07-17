package com.myfschool.schoolevent;

import com.myfschool.account.RoleType;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStatus;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import com.myfschool.notification.NotificationRecipientRepository;
import com.myfschool.schoolevent.dto.SchoolEventItemResponse;
import com.myfschool.schoolevent.dto.SchoolEventListResponse;
import com.myfschool.student.Student;
import com.myfschool.student.StudentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SchoolEventQueryService {

    private final SchoolEventRepository schoolEventRepository;
    private final SchoolEventMapper schoolEventMapper;
    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final StudentRepository studentRepository;
    private final NotificationRecipientRepository notificationRecipientRepository;

    public SchoolEventQueryService(
            SchoolEventRepository schoolEventRepository,
            SchoolEventMapper schoolEventMapper,
            ParentRepository parentRepository,
            ParentStudentRepository parentStudentRepository,
            StudentRepository studentRepository,
            NotificationRecipientRepository notificationRecipientRepository
    ) {
        this.schoolEventRepository = schoolEventRepository;
        this.schoolEventMapper = schoolEventMapper;
        this.parentRepository = parentRepository;
        this.parentStudentRepository = parentStudentRepository;
        this.studentRepository = studentRepository;
        this.notificationRecipientRepository = notificationRecipientRepository;
    }

    @Transactional(readOnly = true)
    public SchoolEventItemResponse getAccessibleEvent(
            Long accountId,
            RoleType activeRole,
            Long eventId
    ) {
        if (activeRole != RoleType.PARENT && activeRole != RoleType.STUDENT) {
            throw new BusinessException(
                    ErrorCode.FORBIDDEN,
                    HttpStatus.FORBIDDEN,
                    "Chỉ phụ huynh hoặc học sinh được xem chi tiết sự kiện này"
            );
        }

        var event = schoolEventRepository.findAccessibleDetail(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Sự kiện"));
        var currentlyVisible = switch (activeRole) {
            case PARENT -> isCurrentlyVisibleToParent(accountId, event);
            case STUDENT -> isCurrentlyVisibleToStudent(accountId, event);
            default -> false;
        };
        var wasRecipient = notificationRecipientRepository
                .existsSchoolEventRecipient(accountId, eventId);

        if (!currentlyVisible && !wasRecipient) {
            throw new ResourceNotFoundException("Sự kiện");
        }
        return schoolEventMapper.toItemResponse(event);
    }

    @Transactional(readOnly = true)
    public SchoolEventListResponse getParentStudentEvents(
            Long accountId,
            Long studentId,
            SchoolEventTimeRange requestedTimeRange,
            SchoolEventViewScope requestedViewScope
    ) {
        var parent = parentRepository
                .findByAccountIdAndStatus(accountId, ParentStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ phụ huynh"));
        var linkedStudent = parentStudentRepository
                .findLinkedStudent(parent.getId(), studentId, ParentStudentStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.FORBIDDEN,
                        HttpStatus.FORBIDDEN,
                        "Bạn không có quyền xem sự kiện của học sinh này"
                ));

        return loadEvents(
                linkedStudent.getStudent(),
                requestedTimeRange,
                requestedViewScope
        );
    }

    @Transactional(readOnly = true)
    public SchoolEventListResponse getStudentEvents(
            Long accountId,
            SchoolEventTimeRange requestedTimeRange,
            SchoolEventViewScope requestedViewScope
    ) {
        var student = studentRepository
                .findByAccountIdWithCurrentClass(accountId)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ học sinh"));

        return loadEvents(student, requestedTimeRange, requestedViewScope);
    }

    private SchoolEventListResponse loadEvents(
            Student student,
            SchoolEventTimeRange requestedTimeRange,
            SchoolEventViewScope requestedViewScope
    ) {
        var timeRange = requestedTimeRange == null
                ? SchoolEventTimeRange.UPCOMING
                : requestedTimeRange;
        var viewScope = requestedViewScope == null
                ? SchoolEventViewScope.ALL
                : requestedViewScope;
        var schoolClass = student.getCurrentClass();
        var classId = schoolClass == null ? null : schoolClass.getId();
        var eventScope = toRepositoryScope(viewScope);
        var now = LocalDateTime.now();

        List<SchoolEvent> events = switch (timeRange) {
            case UPCOMING -> schoolEventRepository.findUpcomingVisibleEvents(
                    classId,
                    eventScope,
                    now.toLocalDate(),
                    now.toLocalTime()
            );
            case PAST -> schoolEventRepository.findPastVisibleEvents(
                    classId,
                    eventScope,
                    now.toLocalDate(),
                    now.toLocalTime()
            );
        };

        return schoolEventMapper.toListResponse(student, timeRange, viewScope, events);
    }

    private SchoolEventScope toRepositoryScope(SchoolEventViewScope viewScope) {
        return switch (viewScope) {
            case ALL -> null;
            case CLASS -> SchoolEventScope.CLASS;
            case SCHOOL -> SchoolEventScope.SCHOOL;
        };
    }

    private boolean isCurrentlyVisibleToParent(Long accountId, SchoolEvent event) {
        var parent = parentRepository
                .findByAccountIdAndStatus(accountId, ParentStatus.ACTIVE)
                .orElse(null);
        if (parent == null) {
            return false;
        }
        var linkedStudents = parentStudentRepository.findLinkedStudents(
                parent.getId(),
                ParentStudentStatus.ACTIVE
        );
        if (event.getScope() == SchoolEventScope.SCHOOL) {
            return !linkedStudents.isEmpty();
        }
        var eventClass = event.getSchoolClass();
        return eventClass != null && linkedStudents.stream()
                .map(link -> link.getStudent().getCurrentClass())
                .anyMatch(currentClass -> currentClass != null
                        && currentClass.getId().equals(eventClass.getId()));
    }

    private boolean isCurrentlyVisibleToStudent(Long accountId, SchoolEvent event) {
        var student = studentRepository.findByAccountIdWithCurrentClass(accountId)
                .orElse(null);
        if (student == null) {
            return false;
        }
        if (event.getScope() == SchoolEventScope.SCHOOL) {
            return true;
        }
        var eventClass = event.getSchoolClass();
        var currentClass = student.getCurrentClass();
        return eventClass != null
                && currentClass != null
                && currentClass.getId().equals(eventClass.getId());
    }
}
