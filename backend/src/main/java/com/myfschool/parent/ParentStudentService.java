package com.myfschool.parent;

import com.myfschool.academic.SchoolClass;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.parent.dto.LinkedStudentResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ParentStudentService {

    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;

    public ParentStudentService(
            ParentRepository parentRepository,
            ParentStudentRepository parentStudentRepository
    ) {
        this.parentRepository = parentRepository;
        this.parentStudentRepository = parentStudentRepository;
    }

    @Transactional(readOnly = true)
    public List<LinkedStudentResponse> getLinkedStudents(Long accountId) {
        var parent = parentRepository
                .findByAccountIdAndStatus(accountId, ParentStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ phụ huynh"));

        return parentStudentRepository
                .findLinkedStudents(parent.getId(), ParentStudentStatus.ACTIVE)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private LinkedStudentResponse toResponse(ParentStudent parentStudent) {
        var student = parentStudent.getStudent();
        SchoolClass schoolClass = student.getCurrentClass();

        return new LinkedStudentResponse(
                student.getId(),
                student.getStudentCode(),
                student.getFullName(),
                schoolClass == null ? null : schoolClass.getId(),
                schoolClass == null ? null : schoolClass.getClassName(),
                parentStudent.getRelationship(),
                parentStudent.isPrimaryContact()
        );
    }
}
