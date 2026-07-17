package com.myfschool.leaveabsence;

import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.leaveabsence.dto.CreateLeaveRequestRequest;
import com.myfschool.leaveabsence.dto.LeaveRequestResponse;
import com.myfschool.parent.Parent;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStatus;
import com.myfschool.parent.ParentStudent;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ParentLeaveRequestService {

    private static final int MAX_NOTE_LENGTH = 2000;
    private static final List<LeaveRequestStatus> OVERLAPPING_STATUSES = List.of(
            LeaveRequestStatus.PENDING,
            LeaveRequestStatus.APPROVED
    );

    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final LeaveRequestMapper leaveRequestMapper;

    public ParentLeaveRequestService(
            ParentRepository parentRepository,
            ParentStudentRepository parentStudentRepository,
            LeaveRequestRepository leaveRequestRepository,
            LeaveRequestMapper leaveRequestMapper
    ) {
        this.parentRepository = parentRepository;
        this.parentStudentRepository = parentStudentRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.leaveRequestMapper = leaveRequestMapper;
    }

    @Transactional(readOnly = true)
    public List<LeaveRequestResponse> getLeaveRequests(
            Long accountId,
            Long studentId,
            LeaveRequestStatus status
    ) {
        var parent = requireActiveParent(accountId);
        requireActiveLink(parent.getId(), studentId);

        return leaveRequestRepository
                .findForParent(parent.getId(), studentId, status)
                .stream()
                .map(leaveRequestMapper::toResponse)
                .toList();
    }

    @Transactional
    public LeaveRequestResponse createLeaveRequest(
            Long accountId,
            Long studentId,
            CreateLeaveRequestRequest request
    ) {
        validateCreateRequest(request);
        var parent = requireActiveParent(accountId);
        var parentStudent = requireActiveLink(parent.getId(), studentId);
        var student = parentStudent.getStudent();
        var schoolClass = student.getCurrentClass();

        if (schoolClass == null) {
            throw new ResourceNotFoundException("Lớp hiện tại của học sinh");
        }

        var overlapCount = leaveRequestRepository.countOverlappingRequests(
                student.getId(),
                request.fromDate(),
                request.toDate(),
                OVERLAPPING_STATUSES
        );
        if (overlapCount > 0) {
            throw new BusinessException(
                    ErrorCode.LEAVE_REQUEST_DATE_OVERLAP,
                    HttpStatus.CONFLICT,
                    "Khoảng ngày xin nghỉ trùng với đơn đang chờ hoặc đã được duyệt"
            );
        }

        var leaveRequest = new LeaveRequest(
                student,
                parent,
                schoolClass,
                request.fromDate(),
                request.toDate(),
                request.reason().trim()
        );
        return leaveRequestMapper.toResponse(leaveRequestRepository.save(leaveRequest));
    }

    @Transactional
    public LeaveRequestResponse cancelLeaveRequest(Long accountId, Long requestId) {
        var parent = requireActiveParent(accountId);
        var leaveRequest = leaveRequestRepository
                .findDetailedById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Đơn xin nghỉ"));

        if (!leaveRequest.getParent().getId().equals(parent.getId())) {
            throw new BusinessException(
                    ErrorCode.FORBIDDEN,
                    HttpStatus.FORBIDDEN,
                    "Bạn không có quyền hủy đơn xin nghỉ này"
            );
        }
        if (leaveRequest.getStatus() != LeaveRequestStatus.PENDING) {
            throw new BusinessException(
                    ErrorCode.LEAVE_REQUEST_ALREADY_PROCESSED,
                    HttpStatus.CONFLICT,
                    "Chỉ đơn đang chờ xử lý mới có thể hủy"
            );
        }

        leaveRequest.cancel();
        return leaveRequestMapper.toResponse(leaveRequest);
    }

    private Parent requireActiveParent(Long accountId) {
        return parentRepository
                .findByAccountIdAndStatus(accountId, ParentStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ phụ huynh"));
    }

    private ParentStudent requireActiveLink(Long parentId, Long studentId) {
        return parentStudentRepository
                .findLinkedStudent(parentId, studentId, ParentStudentStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.FORBIDDEN,
                        HttpStatus.FORBIDDEN,
                        "Bạn không có quyền thao tác với học sinh này"
                ));
    }

    private void validateCreateRequest(CreateLeaveRequestRequest request) {
        if (request == null || request.fromDate() == null || request.toDate() == null) {
            throw validationError("Ngày bắt đầu và ngày kết thúc là bắt buộc");
        }
        if (request.fromDate().isAfter(request.toDate())) {
            throw validationError("Ngày bắt đầu không được sau ngày kết thúc");
        }
        if (request.reason() == null || request.reason().isBlank()) {
            throw validationError("Lý do xin nghỉ là bắt buộc");
        }
        if (request.reason().length() > MAX_NOTE_LENGTH) {
            throw validationError("Lý do xin nghỉ không được vượt quá 2.000 ký tự");
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
