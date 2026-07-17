package com.myfschool.teacher;

import com.myfschool.academic.AcademicYear;
import com.myfschool.academic.AcademicYearRepository;
import com.myfschool.academic.AcademicYearStatus;
import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.academic.Subject;
import com.myfschool.common.exception.ResourceNotFoundException;
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
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TeacherHomeServiceTests {

    @Mock
    private TeacherRepository teacherRepository;

    @Mock
    private AcademicYearRepository academicYearRepository;

    @Mock
    private SchoolClassRepository schoolClassRepository;

    @Mock
    private TeachingAssignmentRepository teachingAssignmentRepository;

    private TeacherHomeService service;

    @BeforeEach
    void setUp() {
        service = new TeacherHomeService(
                teacherRepository,
                academicYearRepository,
                schoolClassRepository,
                teachingAssignmentRepository
        );
    }

    @Test
    void returnsHomeroomClassAndDistinctTeachingAssignments() {
        var teacher = teacher(20L, "TCH001", "Giáo viên Test");
        var academicYear = academicYear(1L, "2026-2027");
        var schoolClass = schoolClass(40L, "10A1", "Lớp 10A1");
        var subject = subject(50L, "TOAN", "Toán");
        var firstAssignment = assignment(subject, schoolClass);
        var duplicateAssignment = assignment(subject, schoolClass);

        stubActiveTeacherAndYear(10L, teacher, academicYear);
        when(schoolClassRepository.findHomeroomClasses(20L, 1L))
                .thenReturn(List.of(schoolClass));
        when(teachingAssignmentRepository.findByTeacherAndAcademicYear(
                20L,
                1L,
                TeachingAssignmentStatus.ACTIVE
        )).thenReturn(List.of(firstAssignment, duplicateAssignment));

        var result = service.getHomeSummary(10L);

        assertThat(result.teacherId()).isEqualTo(20L);
        assertThat(result.academicYearName()).isEqualTo("2026-2027");
        assertThat(result.homeroomClasses()).singleElement().satisfies(item -> {
            assertThat(item.classCode()).isEqualTo("10A1");
            assertThat(item.className()).isEqualTo("Lớp 10A1");
        });
        assertThat(result.teachingAssignments()).singleElement().satisfies(item -> {
            assertThat(item.subjectName()).isEqualTo("Toán");
            assertThat(item.classCode()).isEqualTo("10A1");
        });
    }

    @Test
    void returnsTeachingAssignmentForSubjectTeacherWithoutHomeroomClass() {
        var teacher = teacher(21L, "TCH002", "Giáo viên bộ môn");
        var academicYear = academicYear(1L, "2026-2027");
        var schoolClass = schoolClass(41L, "11A1", "Lớp 11A1");
        var subject = subject(51L, "NGU_VAN", "Ngữ văn");
        var teachingAssignment = assignment(subject, schoolClass);

        stubActiveTeacherAndYear(11L, teacher, academicYear);
        when(schoolClassRepository.findHomeroomClasses(21L, 1L))
                .thenReturn(List.of());
        when(teachingAssignmentRepository.findByTeacherAndAcademicYear(
                21L,
                1L,
                TeachingAssignmentStatus.ACTIVE
        )).thenReturn(List.of(teachingAssignment));

        var result = service.getHomeSummary(11L);

        assertThat(result.homeroomClasses()).isEmpty();
        assertThat(result.teachingAssignments()).singleElement().satisfies(item -> {
            assertThat(item.subjectCode()).isEqualTo("NGU_VAN");
            assertThat(item.classCode()).isEqualTo("11A1");
        });
    }

    @Test
    void rejectsAccountWithoutActiveTeacherProfile() {
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getHomeSummary(10L))
                .isInstanceOf(ResourceNotFoundException.class);

        verify(academicYearRepository, never())
                .findFirstByStatusOrderByStartDateDesc(AcademicYearStatus.ACTIVE);
    }

    @Test
    void rejectsRequestWhenThereIsNoActiveAcademicYear() {
        var teacher = mock(Teacher.class);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(academicYearRepository.findFirstByStatusOrderByStartDateDesc(
                AcademicYearStatus.ACTIVE
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getHomeSummary(10L))
                .isInstanceOf(ResourceNotFoundException.class);

        verifyNoInteractions(schoolClassRepository, teachingAssignmentRepository);
    }

    private void stubActiveTeacherAndYear(
            Long accountId,
            Teacher teacher,
            AcademicYear academicYear
    ) {
        when(teacherRepository.findByAccountIdAndStatus(
                accountId,
                TeacherStatus.ACTIVE
        )).thenReturn(Optional.of(teacher));
        when(academicYearRepository.findFirstByStatusOrderByStartDateDesc(
                AcademicYearStatus.ACTIVE
        )).thenReturn(Optional.of(academicYear));
    }

    private Teacher teacher(Long id, String code, String name) {
        var teacher = mock(Teacher.class);
        when(teacher.getId()).thenReturn(id);
        when(teacher.getTeacherCode()).thenReturn(code);
        when(teacher.getFullName()).thenReturn(name);
        return teacher;
    }

    private AcademicYear academicYear(Long id, String name) {
        var academicYear = mock(AcademicYear.class);
        when(academicYear.getId()).thenReturn(id);
        when(academicYear.getName()).thenReturn(name);
        return academicYear;
    }

    private SchoolClass schoolClass(Long id, String code, String name) {
        var schoolClass = mock(SchoolClass.class);
        when(schoolClass.getId()).thenReturn(id);
        when(schoolClass.getClassCode()).thenReturn(code);
        when(schoolClass.getClassName()).thenReturn(name);
        return schoolClass;
    }

    private Subject subject(Long id, String code, String name) {
        var subject = mock(Subject.class);
        when(subject.getId()).thenReturn(id);
        when(subject.getSubjectCode()).thenReturn(code);
        when(subject.getSubjectName()).thenReturn(name);
        return subject;
    }

    private TeachingAssignment assignment(Subject subject, SchoolClass schoolClass) {
        var assignment = mock(TeachingAssignment.class);
        when(assignment.getSubject()).thenReturn(subject);
        when(assignment.getSchoolClass()).thenReturn(schoolClass);
        return assignment;
    }
}
