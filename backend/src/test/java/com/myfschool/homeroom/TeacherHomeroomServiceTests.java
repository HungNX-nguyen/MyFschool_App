package com.myfschool.homeroom;

import com.myfschool.academic.AcademicYear;
import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.SchoolClassRepository;
import com.myfschool.academic.Semester;
import com.myfschool.academic.SemesterRepository;
import com.myfschool.academic.SemesterStatus;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.student.Student;
import com.myfschool.student.StudentClassHistoryRepository;
import com.myfschool.student.StudentClassHistoryStatus;
import com.myfschool.student.StudentStatus;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
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
class TeacherHomeroomServiceTests {

    @Mock
    private TeacherRepository teacherRepository;

    @Mock
    private SchoolClassRepository schoolClassRepository;

    @Mock
    private SemesterRepository semesterRepository;

    @Mock
    private StudentClassHistoryRepository studentClassHistoryRepository;

    private TeacherHomeroomService service;

    @BeforeEach
    void setUp() {
        service = new TeacherHomeroomService(
                teacherRepository,
                schoolClassRepository,
                semesterRepository,
                studentClassHistoryRepository
        );
    }

    @Test
    void returnsAllAssignedHomeroomClassesWithTheirSemesters() {
        var teacher = mock(Teacher.class);
        var currentClass = mock(SchoolClass.class);
        var previousClass = mock(SchoolClass.class);
        var currentYear = mock(AcademicYear.class);
        var previousYear = mock(AcademicYear.class);
        var currentSemester = mock(Semester.class);
        var previousSemester = mock(Semester.class);

        when(teacher.getId()).thenReturn(20L);
        stubSchoolClass(
                currentClass,
                currentYear,
                30L,
                "10A1",
                "Lớp 10A1",
                2L,
                "2026-2027",
                LocalDate.of(2026, 8, 1),
                LocalDate.of(2027, 5, 31)
        );
        stubSchoolClass(
                previousClass,
                previousYear,
                29L,
                "9A1",
                "Lớp 9A1",
                1L,
                "2025-2026",
                LocalDate.of(2025, 8, 1),
                LocalDate.of(2026, 5, 31)
        );
        stubSemester(
                currentSemester,
                5L,
                2L,
                "Học kỳ 1",
                1,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 12, 31),
                SemesterStatus.PLANNED
        );
        stubSemester(
                previousSemester,
                3L,
                1L,
                "Học kỳ 2",
                2,
                LocalDate.of(2026, 1, 5),
                LocalDate.of(2026, 5, 31),
                SemesterStatus.CLOSED
        );
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findAllHomeroomClasses(20L))
                .thenReturn(List.of(currentClass, previousClass));
        when(semesterRepository
                .findByAcademicYearIdInOrderByAcademicYearIdAscSemesterIndexAsc(
                        List.of(2L, 1L)
                ))
                .thenReturn(List.of(previousSemester, currentSemester));

        var response = service.getHomeroomClasses(10L);

        assertThat(response).hasSize(2);
        assertThat(response.getFirst()).satisfies(item -> {
            assertThat(item.classCode()).isEqualTo("10A1");
            assertThat(item.academicYearName()).isEqualTo("2026-2027");
            assertThat(item.semesters()).singleElement().satisfies(semester -> {
                assertThat(semester.semesterId()).isEqualTo(5L);
                assertThat(semester.status()).isEqualTo(SemesterStatus.PLANNED);
            });
        });
        assertThat(response.get(1)).satisfies(item -> {
            assertThat(item.classCode()).isEqualTo("9A1");
            assertThat(item.academicYearName()).isEqualTo("2025-2026");
            assertThat(item.semesters()).singleElement().satisfies(semester ->
                    assertThat(semester.status()).isEqualTo(SemesterStatus.CLOSED));
        });
    }

    @Test
    void returnsEmptyClassListWithoutQueryingSemesters() {
        var teacher = mock(Teacher.class);
        when(teacher.getId()).thenReturn(20L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findAllHomeroomClasses(20L))
                .thenReturn(List.of());

        assertThat(service.getHomeroomClasses(10L)).isEmpty();

        verifyNoInteractions(semesterRepository);
    }

    @Test
    void returnsActiveStudentRosterForOwnedHomeroomClass() {
        var teacher = mock(Teacher.class);
        var schoolClass = mock(SchoolClass.class);
        var academicYear = mock(AcademicYear.class);
        var student = mock(Student.class);

        when(teacher.getId()).thenReturn(20L);
        when(schoolClass.getId()).thenReturn(30L);
        when(schoolClass.getClassCode()).thenReturn("10A1");
        when(schoolClass.getClassName()).thenReturn("Lớp 10A1");
        when(schoolClass.getAcademicYear()).thenReturn(academicYear);
        when(academicYear.getId()).thenReturn(1L);
        when(academicYear.getName()).thenReturn("2026-2027");
        when(student.getId()).thenReturn(40L);
        when(student.getStudentCode()).thenReturn("STU040");
        when(student.getFullName()).thenReturn("Học sinh Test");
        when(student.getStatus()).thenReturn(StudentStatus.ACTIVE);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(
                30L,
                20L
        )).thenReturn(Optional.of(schoolClass));
        when(studentClassHistoryRepository.findActiveStudentsForClassAndYear(
                30L,
                1L,
                StudentClassHistoryStatus.ACTIVE,
                StudentStatus.ACTIVE
        )).thenReturn(List.of(student));

        var response = service.getClassRoster(10L, 30L);

        assertThat(response.classCode()).isEqualTo("10A1");
        assertThat(response.academicYearName()).isEqualTo("2026-2027");
        assertThat(response.totalStudents()).isEqualTo(1);
        assertThat(response.students()).singleElement().satisfies(item -> {
            assertThat(item.studentCode()).isEqualTo("STU040");
            assertThat(item.status()).isEqualTo(StudentStatus.ACTIVE);
        });
    }

    @Test
    void rejectsClassThatIsNotOwnedByTeacher() {
        var teacher = mock(Teacher.class);
        when(teacher.getId()).thenReturn(20L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(
                30L,
                20L
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getClassRoster(10L, 30L))
                .isInstanceOfSatisfying(BusinessException.class, error ->
                        assertThat(error.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verify(studentClassHistoryRepository, never())
                .findActiveStudentsForClassAndYear(
                        org.mockito.ArgumentMatchers.anyLong(),
                        org.mockito.ArgumentMatchers.anyLong(),
                        org.mockito.ArgumentMatchers.any(),
                        org.mockito.ArgumentMatchers.any()
                );
    }

    private void stubSchoolClass(
            SchoolClass schoolClass,
            AcademicYear academicYear,
            Long classId,
            String classCode,
            String className,
            Long academicYearId,
            String academicYearName,
            LocalDate academicYearStart,
            LocalDate academicYearEnd
    ) {
        when(schoolClass.getId()).thenReturn(classId);
        when(schoolClass.getClassCode()).thenReturn(classCode);
        when(schoolClass.getClassName()).thenReturn(className);
        when(schoolClass.getAcademicYear()).thenReturn(academicYear);
        when(academicYear.getId()).thenReturn(academicYearId);
        when(academicYear.getName()).thenReturn(academicYearName);
        when(academicYear.getStartDate()).thenReturn(academicYearStart);
        when(academicYear.getEndDate()).thenReturn(academicYearEnd);
    }

    private void stubSemester(
            Semester semester,
            Long semesterId,
            Long academicYearId,
            String semesterName,
            int semesterIndex,
            LocalDate startDate,
            LocalDate endDate,
            SemesterStatus status
    ) {
        when(semester.getId()).thenReturn(semesterId);
        when(semester.getAcademicYearId()).thenReturn(academicYearId);
        when(semester.getName()).thenReturn(semesterName);
        when(semester.getSemesterIndex()).thenReturn(semesterIndex);
        when(semester.getStartDate()).thenReturn(startDate);
        when(semester.getEndDate()).thenReturn(endDate);
        when(semester.getStatus()).thenReturn(status);
    }
}
