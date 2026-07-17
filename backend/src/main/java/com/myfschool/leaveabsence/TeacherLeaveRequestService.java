package com.myfschool.leaveabsence;

import com.myfschool.academic.AcademicYearRepository;
import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.leaveabsence.dto.HomeroomClassResponse;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.leaveabsence.dto.ReviewLeaveRequestRequest;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class TeacherLeaveRequestService {

    private static final int MAX_REVIEW_NOTE_LENGTH = 2000;

    private final TeacherRepository teacherRepository;
    private final AcademicYearRepository academicYearRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final AbsenceRecordRepository absenceRecordRepository;
    private final LeaveRequestMapper leaveRequestMapper;

    public TeacherLeaveRequestService(
            TeacherRepository teacherRepository,
            AcademicYearRepository academicYearRepository,
            SchoolClassRepository schoolClassRepository,
            LeaveRequestRepository leaveRequestRepository,
            AbsenceRecordRepository absenceRecordRepository,
            LeaveRequestMapper leaveRequestMapper
    ) {
        this.teacherRepository = teacherRepository;
        this.academicYearRepository = academicYearRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.absenceRecordRepository = absenceRecordRepository;
        this.leaveRequestMapper = leaveRequestMapper;
    }

    @Transactional(readOnly = true)
    public List<HomeroomClassResponse> getHomeroomClasses(Long accountId) {
        var teacher = requireActiveTeacher(accountId);
        var academicYear = academicYearRepository
                .findFirstByStatusOrderByStartDateDesc(AcademicYearStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Năm học đang hoạt động"
                ));

        return schoolClassRepository
                .findHomeroomClasses(teacher.getId(), academicYear.getId())
                .stream()
                .map(leaveRequestMapper::toHomeroomClassResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LeaveRequestResponse> getLeaveRequests(
            Long accountId,
            Long classId,
            LeaveRequestStatus status
    ) {
        var teacher = requireActiveTeacher(accountId);
        requireHomeroomClass(teacher, classId);
        var resolvedStatus = status == null ? LeaveRequestStatus.PENDING : status;

        return leaveRequestRepository
                .findForHomeroomClass(classId, resolvedStatus)
                .stream()
                .map(leaveRequestMapper::toResponse)
                .toList();
    }

    @Transactional
    public LeaveRequestResponse reviewLeaveRequest(
            Long accountId,
            Long requestId,
            ReviewLeaveRequestRequest reviewRequest
    ) {
        validateReviewRequest(reviewRequest);
        var teacher = requireActiveTeacher(accountId);
        var leaveRequest = leaveRequestRepository
                .findDetailedById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Đơn xin nghỉ"));

        requireHomeroomTeacher(teacher, leaveRequest.getSchoolClass());
        if (leaveRequest.getStatus() != LeaveRequestStatus.PENDING) {
            throw new BusinessException(
                    ErrorCode.LEAVE_REQUEST_ALREADY_PROCESSED,
                    HttpStatus.CONFLICT,
                    "Đơn xin nghỉ đã được xử lý"
            );
        }

        var reviewTime = LocalDateTime.now();
        if (reviewRequest.decision() == LeaveRequestStatus.APPROVED) {
            leaveRequest.approve(teacher, reviewTime, reviewRequest.reviewNote());
            absenceRecordRepository.saveAll(createAbsenceRecords(leaveRequest, teacher));
        } else {
            leaveRequest.reject(teacher, reviewTime, reviewRequest.reviewNote());
        }

        return leaveRequestMapper.toResponse(leaveRequest);
    }

    private List<AbsenceRecord> createAbsenceRecords(
            LeaveRequest leaveRequest,
            Teacher teacher
    ) {
        var records = new ArrayList<AbsenceRecord>();
        LocalDate currentDate = leaveRequest.getFromDate();
        while (!currentDate.isAfter(leaveRequest.getToDate())) {
            records.add(new AbsenceRecord(
                    leaveRequest.getStudent(),
                    leaveRequest.getSchoolClass(),
                    currentDate,
                    AbsenceStatus.EXCUSED_ABSENT,
                    AbsenceSource.LEAVE_REQUEST,
                    leaveRequest,
                    teacher,
                    leaveRequest.getReason()
            ));
            currentDate = currentDate.plusDays(1);
        }
        return records;
    }

    private Teacher requireActiveTeacher(Long accountId) {
        return teacherRepository
                .findByAccountIdAndStatus(accountId, TeacherStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ giáo viên"));
    }

    private SchoolClass requireHomeroomClass(Teacher teacher, Long classId) {
        var schoolClass = schoolClassRepository
                .findById(classId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học"));
        requireHomeroomTeacher(teacher, schoolClass);
        return schoolClass;
    }

    private void requireHomeroomTeacher(Teacher teacher, SchoolClass schoolClass) {
        var homeroomTeacher = schoolClass.getHomeroomTeacher();
        if (homeroomTeacher == null || !homeroomTeacher.getId().equals(teacher.getId())) {
            throw new BusinessException(
                    ErrorCode.FORBIDDEN,
                    HttpStatus.FORBIDDEN,
                    "Bạn không phải giáo viên chủ nhiệm của lớp này"
            );
        }
    }

    private void validateReviewRequest(ReviewLeaveRequestRequest request) {
        if (request == null || request.decision() == null) {
            throw validationError("Quyết định duyệt đơn là bắt buộc");
        }
        if (request.decision() != LeaveRequestStatus.APPROVED
                && request.decision() != LeaveRequestStatus.REJECTED) {
            throw validationError("Quyết định chỉ nhận APPROVED hoặc REJECTED");
        }
        if (request.reviewNote() != null
                && request.reviewNote().length() > MAX_REVIEW_NOTE_LENGTH) {
            throw validationError("Ghi chú xử lý không được vượt quá 2.000 ký tự");
        }
        if (request.decision() == LeaveRequestStatus.REJECTED
                && (request.reviewNote() == null || request.reviewNote().isBlank())) {
            throw validationError("Lý do từ chối là bắt buộc");
        }
    }

    private BusinessException validationError(String message) {
        return new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                HttpStatus.BAD_REQUEST,
                message
        );
    }
}
