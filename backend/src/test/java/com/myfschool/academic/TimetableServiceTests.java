package com.myfschool.academic;

import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.parent.Parent;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import com.myfschool.student.Student;
import com.myfschool.student.StudentRepository;
import com.myfschool.student.StudentStudyGroup;
import com.myfschool.student.StudentStudyGroupRepository;
import com.myfschool.student.StudentStudyGroupStatus;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
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
class TimetableServiceTests {

    @Mock
    private TimetableRepository timetableRepository;

    @Mock
    private SemesterRepository semesterRepository;

    @Mock
    private SchoolClassRepository schoolClassRepository;

    @Mock
    private ParentRepository parentRepository;

    @Mock
    private ParentStudentRepository parentStudentRepository;

    @Mock
    private StudentRepository studentRepository;

    @Mock
    private StudentStudyGroupRepository studentStudyGroupRepository;

    @Mock
    private StudyGroupRepository studyGroupRepository;

    @Mock
    private TeacherRepository teacherRepository;

    private TimetableService timetableService;

    @BeforeEach
    void setUp() {
        timetableService = new TimetableService(
                timetableRepository,
                semesterRepository,
                schoolClassRepository,
                parentRepository,
                parentStudentRepository,
                studentRepository,
                studentStudyGroupRepository,
                studyGroupRepository,
                teacherRepository
        );
    }

    @Test
    void rejectsParentWhenStudentIsNotLinked() {
        var parent = mock(Parent.class);
        when(parent.getId()).thenReturn(20L);
        when(parentRepository.findByAccountIdAndStatus(10L, com.myfschool.parent.ParentStatus.ACTIVE))
                .thenReturn(Optional.of(parent));
        when(parentStudentRepository.findLinkedStudent(
                20L,
                30L,
                ParentStudentStatus.ACTIVE
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> timetableService.getParentStudentTimetable(
                10L,
                30L,
                1L,
                LocalDate.of(2026, 8, 3)
        )).isInstanceOfSatisfying(BusinessException.class, error ->
                assertThat(error.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verify(timetableRepository, never()).findClassTimetableForWeek(
                org.mockito.ArgumentMatchers.anyLong(),
                org.mockito.ArgumentMatchers.anyLong(),
                org.mockito.ArgumentMatchers.any(),
                org.mockito.ArgumentMatchers.any(),
                org.mockito.ArgumentMatchers.any(),
                org.mockito.ArgumentMatchers.any()
        );
    }

    @Test
    void buildsSevenDaysAddsFixedActivitiesAndMapsAfternoonSlot() {
        var schoolClass = mock(SchoolClass.class);
        var homeroomTeacher = mock(Teacher.class);
        var student = mock(Student.class);
        var semester = mock(Semester.class);
        var timetable = mock(Timetable.class);
        var subject = mock(Subject.class);
        var subjectTeacher = mock(Teacher.class);
        var lessonSlot = mock(LessonSlot.class);

        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(student.getId()).thenReturn(30L);
        when(schoolClass.getId()).thenReturn(100L);
        when(schoolClass.getClassCode()).thenReturn("10A1");
        when(schoolClass.getClassName()).thenReturn("10A1");
        when(schoolClass.getHomeroomTeacher()).thenReturn(homeroomTeacher);
        when(homeroomTeacher.getId()).thenReturn(200L);
        when(homeroomTeacher.getFullName()).thenReturn("Giáo viên chủ nhiệm");

        when(semester.getId()).thenReturn(1L);
        when(semester.getName()).thenReturn("Học kỳ 1");
        when(semester.getStartDate()).thenReturn(LocalDate.of(2026, 8, 1));
        when(semester.getEndDate()).thenReturn(LocalDate.of(2026, 12, 31));

        when(timetable.getId()).thenReturn(300L);
        when(timetable.getDayOfWeek()).thenReturn(2);
        when(timetable.getSlotIndex()).thenReturn(6);
        when(timetable.getStartTime()).thenReturn(LocalTime.of(13, 30));
        when(timetable.getEndTime()).thenReturn(LocalTime.of(14, 15));
        when(timetable.getEffectiveFrom()).thenReturn(LocalDate.of(2026, 8, 1));
        when(timetable.getEffectiveTo()).thenReturn(LocalDate.of(2026, 12, 31));
        when(timetable.getSubject()).thenReturn(subject);
        when(timetable.getTeacher()).thenReturn(subjectTeacher);
        when(timetable.getLessonSlot()).thenReturn(lessonSlot);
        when(timetable.getRoom()).thenReturn("A101");
        when(lessonSlot.getShift()).thenReturn(LessonShift.AFTERNOON);
        when(subject.getId()).thenReturn(400L);
        when(subject.getSubjectCode()).thenReturn("TOAN");
        when(subject.getSubjectName()).thenReturn("Toán");
        when(subjectTeacher.getId()).thenReturn(500L);
        when(subjectTeacher.getFullName()).thenReturn("Giáo viên Toán");

        when(studentRepository.findByAccountIdWithCurrentClass(10L))
                .thenReturn(Optional.of(student));
        when(semesterRepository.findOverlappingWeek(
                SemesterStatus.ACTIVE,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(List.of(semester));
        when(studentStudyGroupRepository.findActiveForWeek(
                30L,
                1L,
                StudentStudyGroupStatus.ACTIVE,
                StudyGroupStatus.ACTIVE,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(Optional.empty());
        when(timetableRepository.findClassTimetableForWeek(
                100L,
                1L,
                null,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(List.of(timetable));

        var response = timetableService.getStudentTimetable(
                10L,
                null,
                LocalDate.of(2026, 8, 5)
        );

        assertThat(response.weekStart()).isEqualTo(LocalDate.of(2026, 8, 3));
        assertThat(response.weekEnd()).isEqualTo(LocalDate.of(2026, 8, 9));
        assertThat(response.days()).hasSize(7);
        assertThat(response.days().getFirst().slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Chào cờ");
            assertThat(slot.teacherName()).isEqualTo("Giáo viên chủ nhiệm");
            assertThat(slot.fixedActivity()).isTrue();
        });
        assertThat(response.days().get(1).slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Toán");
            assertThat(slot.shift()).isEqualTo(LessonShift.AFTERNOON);
            assertThat(slot.slotIndex()).isEqualTo(6);
            assertThat(slot.displaySlotIndex()).isEqualTo(1);
            assertThat(slot.fixedActivity()).isFalse();
        });
        assertThat(response.days().get(4).slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Sinh hoạt lớp");
            assertThat(slot.fixedActivity()).isTrue();
        });
    }

    @Test
    void usesStudentsActiveStudyGroupWhenLoadingTimetable() {
        var student = mock(Student.class);
        var schoolClass = mock(SchoolClass.class);
        var semester = mock(Semester.class);
        var membership = mock(StudentStudyGroup.class);
        var studyGroup = mock(StudyGroup.class);

        when(student.getId()).thenReturn(30L);
        when(student.getCurrentClass()).thenReturn(schoolClass);
        when(schoolClass.getId()).thenReturn(100L);
        when(schoolClass.getClassCode()).thenReturn("12A1");
        when(schoolClass.getClassName()).thenReturn("12A1");
        when(semester.getId()).thenReturn(1L);
        when(semester.getName()).thenReturn("Học kỳ 1");
        when(semester.getStartDate()).thenReturn(LocalDate.of(2026, 8, 1));
        when(semester.getEndDate()).thenReturn(LocalDate.of(2026, 12, 31));
        when(membership.getStudyGroup()).thenReturn(studyGroup);
        when(studyGroup.getId()).thenReturn(900L);
        when(studyGroup.getSchoolClass()).thenReturn(schoolClass);

        when(studentRepository.findByAccountIdWithCurrentClass(10L))
                .thenReturn(Optional.of(student));
        when(semesterRepository.findById(1L)).thenReturn(Optional.of(semester));
        when(studentStudyGroupRepository.findActiveForWeek(
                30L,
                1L,
                StudentStudyGroupStatus.ACTIVE,
                StudyGroupStatus.ACTIVE,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(Optional.of(membership));
        when(timetableRepository.findClassTimetableForWeek(
                100L,
                1L,
                900L,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(List.of());

        timetableService.getStudentTimetable(
                10L,
                1L,
                LocalDate.of(2026, 8, 3)
        );

        verify(timetableRepository).findClassTimetableForWeek(
                100L,
                1L,
                900L,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        );
    }

    @Test
    void buildsTeacherTimetableWithClassStudyGroupAndHomeroomActivities() {
        var teacher = mock(Teacher.class);
        var semester = mock(Semester.class);
        var timetable = mock(Timetable.class);
        var subject = mock(Subject.class);
        var schoolClass = mock(SchoolClass.class);
        var studyGroup = mock(StudyGroup.class);
        var lessonSlot = mock(LessonSlot.class);

        when(teacher.getId()).thenReturn(20L);
        when(teacher.getTeacherCode()).thenReturn("TCH020");
        when(teacher.getFullName()).thenReturn("Giáo viên Toán");
        when(semester.getId()).thenReturn(1L);
        when(semester.getAcademicYearId()).thenReturn(100L);
        when(semester.getName()).thenReturn("Học kỳ 1");
        when(semester.getStartDate()).thenReturn(LocalDate.of(2026, 8, 1));
        when(semester.getEndDate()).thenReturn(LocalDate.of(2026, 12, 31));

        when(timetable.getId()).thenReturn(300L);
        when(timetable.getDayOfWeek()).thenReturn(2);
        when(timetable.getSlotIndex()).thenReturn(6);
        when(timetable.getStartTime()).thenReturn(LocalTime.of(13, 30));
        when(timetable.getEndTime()).thenReturn(LocalTime.of(14, 15));
        when(timetable.getEffectiveFrom()).thenReturn(LocalDate.of(2026, 8, 1));
        when(timetable.getEffectiveTo()).thenReturn(LocalDate.of(2026, 12, 31));
        when(timetable.getSubject()).thenReturn(subject);
        when(timetable.getSchoolClass()).thenReturn(schoolClass);
        when(timetable.getStudyGroup()).thenReturn(studyGroup);
        when(timetable.getLessonSlot()).thenReturn(lessonSlot);
        when(timetable.getRoom()).thenReturn("A101");
        when(lessonSlot.getShift()).thenReturn(LessonShift.AFTERNOON);
        when(subject.getId()).thenReturn(400L);
        when(subject.getSubjectCode()).thenReturn("TOAN");
        when(subject.getSubjectName()).thenReturn("Toán");
        when(schoolClass.getId()).thenReturn(500L);
        when(schoolClass.getClassCode()).thenReturn("12A1");
        when(schoolClass.getClassName()).thenReturn("12A1");
        when(studyGroup.getId()).thenReturn(600L);
        when(studyGroup.getGroupName()).thenReturn("12A1 - Cụm Tự nhiên");

        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(semesterRepository.findOverlappingWeek(
                SemesterStatus.ACTIVE,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(List.of(semester));
        when(timetableRepository.findTeacherTimetableForWeek(
                20L,
                1L,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(List.of(timetable));
        when(schoolClassRepository.findHomeroomClasses(20L, 100L))
                .thenReturn(List.of(schoolClass));

        var response = timetableService.getTeacherTimetable(
                10L,
                null,
                LocalDate.of(2026, 8, 5)
        );

        assertThat(response.teacherId()).isEqualTo(20L);
        assertThat(response.teacherCode()).isEqualTo("TCH020");
        assertThat(response.weekStart()).isEqualTo(LocalDate.of(2026, 8, 3));
        assertThat(response.weekEnd()).isEqualTo(LocalDate.of(2026, 8, 9));
        assertThat(response.days()).hasSize(7);
        assertThat(response.days().getFirst().slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Chào cờ");
            assertThat(slot.classCode()).isEqualTo("12A1");
            assertThat(slot.fixedActivity()).isTrue();
        });
        assertThat(response.days().get(1).slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Toán");
            assertThat(slot.classCode()).isEqualTo("12A1");
            assertThat(slot.studyGroupName()).isEqualTo("12A1 - Cụm Tự nhiên");
            assertThat(slot.shift()).isEqualTo(LessonShift.AFTERNOON);
            assertThat(slot.displaySlotIndex()).isEqualTo(1);
            assertThat(slot.fixedActivity()).isFalse();
        });
        assertThat(response.days().get(4).slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Sinh hoạt lớp");
            assertThat(slot.classCode()).isEqualTo("12A1");
            assertThat(slot.fixedActivity()).isTrue();
        });
    }

    @Test
    void buildsHomeroomClassTimetableWithAllStudyGroups() {
        var teacher = mock(Teacher.class);
        var schoolClass = mock(SchoolClass.class);
        var academicYear = mock(AcademicYear.class);
        var semester = mock(Semester.class);
        var studyGroup = mock(StudyGroup.class);
        var timetable = mock(Timetable.class);
        var subject = mock(Subject.class);
        var subjectTeacher = mock(Teacher.class);
        var lessonSlot = mock(LessonSlot.class);

        when(teacher.getId()).thenReturn(20L);
        when(teacher.getFullName()).thenReturn("Giáo viên chủ nhiệm");
        when(schoolClass.getId()).thenReturn(100L);
        when(schoolClass.getClassCode()).thenReturn("12A1");
        when(schoolClass.getClassName()).thenReturn("Lớp 12A1");
        when(schoolClass.getAcademicYear()).thenReturn(academicYear);
        when(schoolClass.getHomeroomTeacher()).thenReturn(teacher);
        when(academicYear.getId()).thenReturn(1L);
        when(semester.getId()).thenReturn(5L);
        when(semester.getAcademicYearId()).thenReturn(1L);
        when(semester.getName()).thenReturn("Học kỳ 1");
        when(semester.getStartDate()).thenReturn(LocalDate.of(2026, 8, 1));
        when(semester.getEndDate()).thenReturn(LocalDate.of(2026, 12, 31));
        when(studyGroup.getId()).thenReturn(900L);
        when(studyGroup.getGroupCode()).thenReturn("12A1-TN");
        when(studyGroup.getGroupName()).thenReturn("Khối Tự nhiên");

        when(timetable.getId()).thenReturn(300L);
        when(timetable.getDayOfWeek()).thenReturn(2);
        when(timetable.getSlotIndex()).thenReturn(6);
        when(timetable.getStartTime()).thenReturn(LocalTime.of(13, 30));
        when(timetable.getEndTime()).thenReturn(LocalTime.of(14, 15));
        when(timetable.getEffectiveFrom()).thenReturn(LocalDate.of(2026, 8, 1));
        when(timetable.getEffectiveTo()).thenReturn(LocalDate.of(2026, 12, 31));
        when(timetable.getSubject()).thenReturn(subject);
        when(timetable.getTeacher()).thenReturn(subjectTeacher);
        when(timetable.getStudyGroup()).thenReturn(studyGroup);
        when(timetable.getLessonSlot()).thenReturn(lessonSlot);
        when(timetable.getRoom()).thenReturn("A101");
        when(lessonSlot.getShift()).thenReturn(LessonShift.AFTERNOON);
        when(subject.getId()).thenReturn(400L);
        when(subject.getSubjectCode()).thenReturn("VAT_LY");
        when(subject.getSubjectName()).thenReturn("Vật lý");
        when(subjectTeacher.getId()).thenReturn(500L);
        when(subjectTeacher.getFullName()).thenReturn("Giáo viên Vật lý");

        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(
                100L,
                20L
        )).thenReturn(Optional.of(schoolClass));
        when(semesterRepository.findById(5L)).thenReturn(Optional.of(semester));
        when(studyGroupRepository.findBySchoolClassIdAndStatusOrderByGroupNameAsc(
                100L,
                StudyGroupStatus.ACTIVE
        )).thenReturn(List.of(studyGroup));
        when(timetableRepository.findHomeroomClassTimetableForWeek(
                100L,
                5L,
                null,
                TimetableStatus.PUBLISHED,
                LocalDate.of(2026, 8, 3),
                LocalDate.of(2026, 8, 9)
        )).thenReturn(List.of(timetable));

        var response = timetableService.getHomeroomClassTimetable(
                10L,
                100L,
                5L,
                LocalDate.of(2026, 8, 5),
                null
        );

        assertThat(response.classCode()).isEqualTo("12A1");
        assertThat(response.weekStart()).isEqualTo(LocalDate.of(2026, 8, 3));
        assertThat(response.selectedStudyGroupId()).isNull();
        assertThat(response.availableStudyGroups()).singleElement().satisfies(group -> {
            assertThat(group.studyGroupId()).isEqualTo(900L);
            assertThat(group.studyGroupName()).isEqualTo("Khối Tự nhiên");
        });
        assertThat(response.days()).hasSize(7);
        assertThat(response.days().getFirst().slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Chào cờ");
            assertThat(slot.fixedActivity()).isTrue();
        });
        assertThat(response.days().get(1).slots()).singleElement().satisfies(slot -> {
            assertThat(slot.subjectName()).isEqualTo("Vật lý");
            assertThat(slot.studyGroupCode()).isEqualTo("12A1-TN");
            assertThat(slot.displaySlotIndex()).isEqualTo(1);
        });
    }

    @Test
    void rejectsHomeroomTimetableForClassOwnedByAnotherTeacher() {
        var teacher = mock(Teacher.class);
        when(teacher.getId()).thenReturn(20L);
        when(teacherRepository.findByAccountIdAndStatus(10L, TeacherStatus.ACTIVE))
                .thenReturn(Optional.of(teacher));
        when(schoolClassRepository.findHomeroomClass(
                100L,
                20L
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() -> timetableService.getHomeroomClassTimetable(
                10L,
                100L,
                5L,
                LocalDate.of(2026, 8, 3),
                null
        )).isInstanceOfSatisfying(BusinessException.class, error ->
                assertThat(error.getErrorCode()).isEqualTo(ErrorCode.FORBIDDEN));

        verifyNoInteractions(studyGroupRepository);
    }
}
