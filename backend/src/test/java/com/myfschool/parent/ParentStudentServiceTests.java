package com.myfschool.parent;

import com.myfschool.academic.SchoolClass;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.student.Student;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ParentStudentServiceTests {

    @Mock
    private ParentRepository parentRepository;

    @Mock
    private ParentStudentRepository parentStudentRepository;

    private ParentStudentService parentStudentService;

    @BeforeEach
    void setUp() {
        parentStudentService = new ParentStudentService(
                parentRepository,
                parentStudentRepository
        );
    }

    @Test
    void returnsActiveLinkedStudentsWithCurrentClass() {
        var parent = mock(Parent.class);
        var parentStudent = mock(ParentStudent.class);
        var student = mock(Student.class);
        var schoolClass = mock(SchoolClass.class);

        when(parent.getId()).thenReturn(20L);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudents(20L, ParentStudentStatus.ACTIVE))
                .thenReturn(List.of(parentStudent));
        when(parentStudent.getStudent()).thenReturn(student);
        when(parentStudent.getRelationship()).thenReturn("MOTHER");
        when(parentStudent.isPrimaryContact()).thenReturn(true);
        when(student.getId()).thenReturn(30L);
        when(student.getStudentCode()).thenReturn("STU0030");
        when(student.getFullName()).thenReturn("Nguyễn Minh An");
        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(schoolClass.getId()).thenReturn(40L);
        when(schoolClass.getClassName()).thenReturn("10A1");

        var result = parentStudentService.getLinkedStudents(10L);

        assertThat(result).singleElement().satisfies(response -> {
            assertThat(response.studentId()).isEqualTo(30L);
            assertThat(response.studentCode()).isEqualTo("STU0030");
            assertThat(response.fullName()).isEqualTo("Nguyễn Minh An");
            assertThat(response.classId()).isEqualTo(40L);
            assertThat(response.className()).isEqualTo("10A1");
            assertThat(response.relationship()).isEqualTo("MOTHER");
            assertThat(response.isPrimaryContact()).isTrue();
        });
        verify(parentStudentRepository)
                .findLinkedStudents(20L, ParentStudentStatus.ACTIVE);
    }

    @Test
    void returnsNullClassFieldsWhenStudentHasNotBeenAssigned() {
        var parent = mock(Parent.class);
        var parentStudent = mock(ParentStudent.class);
        var student = mock(Student.class);

        when(parent.getId()).thenReturn(20L);
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudents(20L, ParentStudentStatus.ACTIVE))
                .thenReturn(List.of(parentStudent));
        when(parentStudent.getStudent()).thenReturn(student);
        when(student.getCurrentClass()).thenReturn(null);

        var response = parentStudentService.getLinkedStudents(10L).getFirst();

        assertThat(response.classId()).isNull();
        assertThat(response.className()).isNull();
    }

    @Test
    void rejectsAccountWithoutActiveParentProfile() {
        when(parentRepository.findByAccountIdAndStatus(10L, ParentStatus.ACTIVE))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> parentStudentService.getLinkedStudents(10L))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
