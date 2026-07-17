package com.myfschool.academic;

import com.myfschool.academic.dto.TimetableDayResponse;
import com.myfschool.academic.dto.TimetableResponse;
import com.myfschool.academic.dto.TimetableSlotResponse;
import com.myfschool.academic.dto.TeacherTimetableDayResponse;
import com.myfschool.academic.dto.TeacherTimetableResponse;
import com.myfschool.academic.dto.TeacherTimetableSlotResponse;
import com.myfschool.common.exception.BusinessException;
import com.myfschool.common.exception.ErrorCode;
import com.myfschool.common.exception.ResourceNotFoundException;
import com.myfschool.homeroom.dto.HomeroomStudyGroupResponse;
import com.myfschool.homeroom.dto.HomeroomTimetableDayResponse;
import com.myfschool.homeroom.dto.HomeroomTimetableResponse;
import com.myfschool.homeroom.dto.HomeroomTimetableSlotResponse;
import com.myfschool.parent.ParentRepository;
import com.myfschool.parent.ParentStatus;
import com.myfschool.parent.ParentStudentRepository;
import com.myfschool.parent.ParentStudentStatus;
import com.myfschool.student.Student;
import com.myfschool.student.StudentRepository;
import com.myfschool.student.StudentStudyGroupRepository;
import com.myfschool.student.StudentStudyGroupStatus;
import com.myfschool.teacher.Teacher;
import com.myfschool.teacher.TeacherRepository;
import com.myfschool.teacher.TeacherStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

@Service
public class TimetableService {

    private static final int DAYS_IN_WEEK = 7;
    private static final int AFTERNOON_SLOT_OFFSET = 5;

    private final TimetableRepository timetableRepository;
    private final SemesterRepository semesterRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final ParentRepository parentRepository;
    private final ParentStudentRepository parentStudentRepository;
    private final StudentRepository studentRepository;
    private final StudentStudyGroupRepository studentStudyGroupRepository;
    private final StudyGroupRepository studyGroupRepository;
    private final TeacherRepository teacherRepository;

    public TimetableService(
            TimetableRepository timetableRepository,
            SemesterRepository semesterRepository,
            SchoolClassRepository schoolClassRepository,
            ParentRepository parentRepository,
            ParentStudentRepository parentStudentRepository,
            StudentRepository studentRepository,
            StudentStudyGroupRepository studentStudyGroupRepository,
            StudyGroupRepository studyGroupRepository,
            TeacherRepository teacherRepository
    ) {
        this.timetableRepository = timetableRepository;
        this.semesterRepository = semesterRepository;
        this.schoolClassRepository = schoolClassRepository;
        this.parentRepository = parentRepository;
        this.parentStudentRepository = parentStudentRepository;
        this.studentRepository = studentRepository;
        this.studentStudyGroupRepository = studentStudyGroupRepository;
        this.studyGroupRepository = studyGroupRepository;
        this.teacherRepository = teacherRepository;
    }

    @Transactional(readOnly = true)
    public TimetableResponse getParentStudentTimetable(
            Long accountId,
            Long studentId,
            Long semesterId,
            LocalDate requestedWeekStart
    ) {
        var parent = parentRepository
                .findByAccountIdAndStatus(accountId, ParentStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ phụ huynh"));

        var parentStudent = parentStudentRepository
                .findLinkedStudent(parent.getId(), studentId, ParentStudentStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.FORBIDDEN,
                        HttpStatus.FORBIDDEN,
                        "Bạn không có quyền xem thời khóa biểu của học sinh này"
                ));

        return buildTimetable(parentStudent.getStudent(), semesterId, requestedWeekStart);
    }

    @Transactional(readOnly = true)
    public TimetableResponse getStudentTimetable(
            Long accountId,
            Long semesterId,
            LocalDate requestedWeekStart
    ) {
        var student = studentRepository
                .findByAccountIdWithCurrentClass(accountId)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ học sinh"));

        return buildTimetable(student, semesterId, requestedWeekStart);
    }

    @Transactional(readOnly = true)
    public TeacherTimetableResponse getTeacherTimetable(
            Long accountId,
            Long semesterId,
            LocalDate requestedWeekStart
    ) {
        var teacher = teacherRepository
                .findByAccountIdAndStatus(accountId, TeacherStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ giáo viên"));

        var weekStart = normalizeWeekStart(requestedWeekStart);
        var weekEnd = weekStart.plusDays(DAYS_IN_WEEK - 1L);
        var semester = resolveSemester(semesterId, weekStart, weekEnd);
        validateWeekOverlapsSemester(weekStart, weekEnd, semester);

        var timetableEntries = timetableRepository.findTeacherTimetableForWeek(
                teacher.getId(),
                semester.getId(),
                TimetableStatus.PUBLISHED,
                weekStart,
                weekEnd
        );
        var homeroomClasses = schoolClassRepository.findHomeroomClasses(
                teacher.getId(),
                semester.getAcademicYearId()
        );

        var days = new ArrayList<TeacherTimetableDayResponse>(DAYS_IN_WEEK);
        for (int dayOfWeek = 1; dayOfWeek <= DAYS_IN_WEEK; dayOfWeek++) {
            int currentDayOfWeek = dayOfWeek;
            var date = weekStart.plusDays(dayOfWeek - 1L);
            var slots = new ArrayList<TeacherTimetableSlotResponse>(timetableEntries.stream()
                    .filter(entry -> entry.getDayOfWeek() == currentDayOfWeek)
                    .filter(entry -> isEffectiveOn(entry, date))
                    .map(this::toTeacherSlotResponse)
                    .toList());

            if (isWithinSemester(date, semester)) {
                homeroomClasses.forEach(schoolClass ->
                        addTeacherFixedHomeroomActivity(
                                slots,
                                currentDayOfWeek,
                                schoolClass
                        ));
            }
            slots.sort(this::compareTeacherSlots);
            days.add(new TeacherTimetableDayResponse(
                    dayOfWeek,
                    date,
                    List.copyOf(slots)
            ));
        }

        return new TeacherTimetableResponse(
                teacher.getId(),
                teacher.getTeacherCode(),
                teacher.getFullName(),
                semester.getId(),
                semester.getName(),
                weekStart,
                weekEnd,
                List.copyOf(days)
        );
    }

    @Transactional(readOnly = true)
    public HomeroomTimetableResponse getHomeroomClassTimetable(
            Long accountId,
            Long classId,
            Long semesterId,
            LocalDate requestedWeekStart,
            Long studyGroupId
    ) {
        var teacher = teacherRepository
                .findByAccountIdAndStatus(accountId, TeacherStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Hồ sơ giáo viên"));
        var schoolClass = schoolClassRepository
                .findHomeroomClass(
                        classId,
                        teacher.getId()
                )
                .orElseThrow(this::homeroomAccessDenied);

        var weekStart = normalizeWeekStart(requestedWeekStart);
        var weekEnd = weekStart.plusDays(DAYS_IN_WEEK - 1L);
        var semester = resolveSemester(semesterId, weekStart, weekEnd);
        validateWeekOverlapsSemester(weekStart, weekEnd, semester);
        validateSemesterBelongsToClass(semester, schoolClass);

        var studyGroups = studyGroupRepository
                .findBySchoolClassIdAndStatusOrderByGroupNameAsc(
                        schoolClass.getId(),
                        StudyGroupStatus.ACTIVE
                );
        validateSelectedStudyGroup(studyGroupId, studyGroups);

        var timetableEntries = timetableRepository.findHomeroomClassTimetableForWeek(
                schoolClass.getId(),
                semester.getId(),
                studyGroupId,
                TimetableStatus.PUBLISHED,
                weekStart,
                weekEnd
        );

        var days = new ArrayList<HomeroomTimetableDayResponse>(DAYS_IN_WEEK);
        for (int dayOfWeek = 1; dayOfWeek <= DAYS_IN_WEEK; dayOfWeek++) {
            int currentDayOfWeek = dayOfWeek;
            var date = weekStart.plusDays(dayOfWeek - 1L);
            var slots = new ArrayList<HomeroomTimetableSlotResponse>(
                    timetableEntries.stream()
                            .filter(entry -> entry.getDayOfWeek() == currentDayOfWeek)
                            .filter(entry -> isEffectiveOn(entry, date))
                            .map(this::toHomeroomSlotResponse)
                            .toList()
            );

            if (isWithinSemester(date, semester)) {
                addHomeroomFixedActivity(
                        slots,
                        currentDayOfWeek,
                        schoolClass.getHomeroomTeacher()
                );
            }
            slots.sort(this::compareHomeroomSlots);
            days.add(new HomeroomTimetableDayResponse(
                    currentDayOfWeek,
                    date,
                    List.copyOf(slots)
            ));
        }

        var availableStudyGroups = studyGroups.stream()
                .map(group -> new HomeroomStudyGroupResponse(
                        group.getId(),
                        group.getGroupCode(),
                        group.getGroupName()
                ))
                .toList();

        return new HomeroomTimetableResponse(
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                semester.getId(),
                semester.getName(),
                weekStart,
                weekEnd,
                studyGroupId,
                List.copyOf(availableStudyGroups),
                List.copyOf(days)
        );
    }

    private TimetableResponse buildTimetable(
            Student student,
            Long semesterId,
            LocalDate requestedWeekStart
    ) {
        var schoolClass = student.getCurrentClass();
        if (schoolClass == null) {
            throw new ResourceNotFoundException("Lớp hiện tại của học sinh");
        }

        var weekStart = normalizeWeekStart(requestedWeekStart);
        var weekEnd = weekStart.plusDays(DAYS_IN_WEEK - 1L);
        var semester = resolveSemester(semesterId, weekStart, weekEnd);
        validateWeekOverlapsSemester(weekStart, weekEnd, semester);
        var studyGroupId = resolveStudyGroupId(
                student,
                schoolClass,
                semester,
                weekStart,
                weekEnd
        );

        var timetableEntries = timetableRepository.findClassTimetableForWeek(
                schoolClass.getId(),
                semester.getId(),
                studyGroupId,
                TimetableStatus.PUBLISHED,
                weekStart,
                weekEnd
        );

        var days = new ArrayList<TimetableDayResponse>(DAYS_IN_WEEK);
        for (int dayOfWeek = 1; dayOfWeek <= DAYS_IN_WEEK; dayOfWeek++) {
            int currentDayOfWeek = dayOfWeek;
            var date = weekStart.plusDays(dayOfWeek - 1L);
            var slots = new ArrayList<TimetableSlotResponse>(timetableEntries.stream()
                    .filter(entry -> entry.getDayOfWeek() == currentDayOfWeek)
                    .filter(entry -> isEffectiveOn(entry, date))
                    .map(this::toSlotResponse)
                    .toList());

            addFixedHomeroomActivity(slots, dayOfWeek, schoolClass.getHomeroomTeacher());
            slots.sort((left, right) -> Integer.compare(left.slotIndex(), right.slotIndex()));
            days.add(new TimetableDayResponse(dayOfWeek, date, List.copyOf(slots)));
        }

        return new TimetableResponse(
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                semester.getId(),
                semester.getName(),
                weekStart,
                weekEnd,
                List.copyOf(days)
        );
    }

    private Long resolveStudyGroupId(
            Student student,
            SchoolClass schoolClass,
            Semester semester,
            LocalDate weekStart,
            LocalDate weekEnd
    ) {
        return studentStudyGroupRepository
                .findActiveForWeek(
                        student.getId(),
                        semester.getId(),
                        StudentStudyGroupStatus.ACTIVE,
                        StudyGroupStatus.ACTIVE,
                        weekStart,
                        weekEnd
                )
                .filter(membership -> membership
                        .getStudyGroup()
                        .getSchoolClass()
                        .getId()
                        .equals(schoolClass.getId()))
                .map(membership -> membership.getStudyGroup().getId())
                .orElse(null);
    }

    private Semester resolveSemester(
            Long semesterId,
            LocalDate weekStart,
            LocalDate weekEnd
    ) {
        if (semesterId != null) {
            return semesterRepository
                    .findById(semesterId)
                    .orElseThrow(() -> new ResourceNotFoundException("Học kỳ"));
        }

        return semesterRepository
                .findOverlappingWeek(SemesterStatus.ACTIVE, weekStart, weekEnd)
                .stream()
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Học kỳ đang hoạt động trong tuần được chọn"
                ));
    }

    private LocalDate normalizeWeekStart(LocalDate requestedWeekStart) {
        if (requestedWeekStart == null) {
            throw new BusinessException(
                    ErrorCode.VALIDATION_ERROR,
                    HttpStatus.BAD_REQUEST,
                    "weekStart là bắt buộc"
            );
        }
        return requestedWeekStart.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    private void validateWeekOverlapsSemester(
            LocalDate weekStart,
            LocalDate weekEnd,
            Semester semester
    ) {
        if (weekEnd.isBefore(semester.getStartDate())
                || weekStart.isAfter(semester.getEndDate())) {
            throw new BusinessException(
                    ErrorCode.INVALID_REQUEST,
                    HttpStatus.BAD_REQUEST,
                    "Tuần được chọn nằm ngoài học kỳ"
            );
        }
    }

    private boolean isEffectiveOn(Timetable entry, LocalDate date) {
        return !date.isBefore(entry.getEffectiveFrom())
                && (entry.getEffectiveTo() == null || !date.isAfter(entry.getEffectiveTo()));
    }

    private TimetableSlotResponse toSlotResponse(Timetable entry) {
        var lessonSlot = entry.getLessonSlot();
        var shift = lessonSlot == null
                ? resolveShift(entry.getSlotIndex())
                : lessonSlot.getShift();

        return new TimetableSlotResponse(
                entry.getId(),
                entry.getSlotIndex(),
                toDisplaySlotIndex(entry.getSlotIndex(), shift),
                shift,
                entry.getStartTime(),
                entry.getEndTime(),
                entry.getSubject().getId(),
                entry.getSubject().getSubjectCode(),
                entry.getSubject().getSubjectName(),
                entry.getTeacher().getId(),
                entry.getTeacher().getFullName(),
                entry.getRoom(),
                false
        );
    }

    private HomeroomTimetableSlotResponse toHomeroomSlotResponse(
            Timetable entry
    ) {
        var lessonSlot = entry.getLessonSlot();
        var shift = lessonSlot == null
                ? resolveShift(entry.getSlotIndex())
                : lessonSlot.getShift();
        var studyGroup = entry.getStudyGroup();

        return new HomeroomTimetableSlotResponse(
                entry.getId(),
                entry.getSlotIndex(),
                toDisplaySlotIndex(entry.getSlotIndex(), shift),
                shift,
                entry.getStartTime(),
                entry.getEndTime(),
                entry.getSubject().getId(),
                entry.getSubject().getSubjectCode(),
                entry.getSubject().getSubjectName(),
                entry.getTeacher().getId(),
                entry.getTeacher().getFullName(),
                studyGroup == null ? null : studyGroup.getId(),
                studyGroup == null ? null : studyGroup.getGroupCode(),
                studyGroup == null ? null : studyGroup.getGroupName(),
                entry.getRoom(),
                false
        );
    }

    private TeacherTimetableSlotResponse toTeacherSlotResponse(Timetable entry) {
        var lessonSlot = entry.getLessonSlot();
        var shift = lessonSlot == null
                ? resolveShift(entry.getSlotIndex())
                : lessonSlot.getShift();
        var schoolClass = entry.getSchoolClass();
        var studyGroup = entry.getStudyGroup();

        return new TeacherTimetableSlotResponse(
                entry.getId(),
                entry.getSlotIndex(),
                toDisplaySlotIndex(entry.getSlotIndex(), shift),
                shift,
                entry.getStartTime(),
                entry.getEndTime(),
                entry.getSubject().getId(),
                entry.getSubject().getSubjectCode(),
                entry.getSubject().getSubjectName(),
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                studyGroup == null ? null : studyGroup.getId(),
                studyGroup == null ? null : studyGroup.getGroupName(),
                entry.getRoom(),
                false
        );
    }

    private void addTeacherFixedHomeroomActivity(
            List<TeacherTimetableSlotResponse> slots,
            int dayOfWeek,
            SchoolClass schoolClass
    ) {
        if (dayOfWeek == DayOfWeek.MONDAY.getValue()) {
            slots.add(teacherFixedActivity(
                    1,
                    LocalTime.of(7, 30),
                    LocalTime.of(8, 15),
                    "Chào cờ",
                    schoolClass
            ));
        }
        if (dayOfWeek == DayOfWeek.FRIDAY.getValue()) {
            slots.add(teacherFixedActivity(
                    5,
                    LocalTime.of(11, 10),
                    LocalTime.of(11, 55),
                    "Sinh hoạt lớp",
                    schoolClass
            ));
        }
    }

    private void addHomeroomFixedActivity(
            List<HomeroomTimetableSlotResponse> slots,
            int dayOfWeek,
            Teacher homeroomTeacher
    ) {
        if (dayOfWeek == DayOfWeek.MONDAY.getValue()) {
            slots.add(homeroomFixedActivity(
                    1,
                    LocalTime.of(7, 30),
                    LocalTime.of(8, 15),
                    "Chào cờ",
                    homeroomTeacher
            ));
        }
        if (dayOfWeek == DayOfWeek.FRIDAY.getValue()) {
            slots.add(homeroomFixedActivity(
                    5,
                    LocalTime.of(11, 10),
                    LocalTime.of(11, 55),
                    "Sinh hoạt lớp",
                    homeroomTeacher
            ));
        }
    }

    private HomeroomTimetableSlotResponse homeroomFixedActivity(
            int slotIndex,
            LocalTime startTime,
            LocalTime endTime,
            String activityName,
            Teacher homeroomTeacher
    ) {
        return new HomeroomTimetableSlotResponse(
                null,
                slotIndex,
                slotIndex,
                LessonShift.MORNING,
                startTime,
                endTime,
                null,
                null,
                activityName,
                homeroomTeacher == null ? null : homeroomTeacher.getId(),
                homeroomTeacher == null ? null : homeroomTeacher.getFullName(),
                null,
                null,
                null,
                null,
                true
        );
    }

    private int compareHomeroomSlots(
            HomeroomTimetableSlotResponse left,
            HomeroomTimetableSlotResponse right
    ) {
        int slotComparison = Integer.compare(left.slotIndex(), right.slotIndex());
        if (slotComparison != 0) {
            return slotComparison;
        }
        if (left.studyGroupName() == null && right.studyGroupName() != null) {
            return -1;
        }
        if (left.studyGroupName() != null && right.studyGroupName() == null) {
            return 1;
        }
        if (left.studyGroupName() != null) {
            int groupComparison = left.studyGroupName()
                    .compareTo(right.studyGroupName());
            if (groupComparison != 0) {
                return groupComparison;
            }
        }
        return left.subjectName().compareTo(right.subjectName());
    }

    private TeacherTimetableSlotResponse teacherFixedActivity(
            int slotIndex,
            LocalTime startTime,
            LocalTime endTime,
            String activityName,
            SchoolClass schoolClass
    ) {
        return new TeacherTimetableSlotResponse(
                null,
                slotIndex,
                slotIndex,
                LessonShift.MORNING,
                startTime,
                endTime,
                null,
                null,
                activityName,
                schoolClass.getId(),
                schoolClass.getClassCode(),
                schoolClass.getClassName(),
                null,
                null,
                null,
                true
        );
    }

    private int compareTeacherSlots(
            TeacherTimetableSlotResponse left,
            TeacherTimetableSlotResponse right
    ) {
        int slotComparison = Integer.compare(left.slotIndex(), right.slotIndex());
        if (slotComparison != 0) {
            return slotComparison;
        }
        return left.classCode().compareTo(right.classCode());
    }

    private boolean isWithinSemester(LocalDate date, Semester semester) {
        return !date.isBefore(semester.getStartDate())
                && !date.isAfter(semester.getEndDate());
    }

    private void addFixedHomeroomActivity(
            List<TimetableSlotResponse> slots,
            int dayOfWeek,
            Teacher homeroomTeacher
    ) {
        if (dayOfWeek == DayOfWeek.MONDAY.getValue()) {
            slots.add(fixedActivity(
                    1,
                    LocalTime.of(7, 30),
                    LocalTime.of(8, 15),
                    "Chào cờ",
                    homeroomTeacher
            ));
        }
        if (dayOfWeek == DayOfWeek.FRIDAY.getValue()) {
            slots.add(fixedActivity(
                    5,
                    LocalTime.of(11, 10),
                    LocalTime.of(11, 55),
                    "Sinh hoạt lớp",
                    homeroomTeacher
            ));
        }
    }

    private TimetableSlotResponse fixedActivity(
            int slotIndex,
            LocalTime startTime,
            LocalTime endTime,
            String activityName,
            Teacher homeroomTeacher
    ) {
        return new TimetableSlotResponse(
                null,
                slotIndex,
                slotIndex,
                LessonShift.MORNING,
                startTime,
                endTime,
                null,
                null,
                activityName,
                homeroomTeacher == null ? null : homeroomTeacher.getId(),
                homeroomTeacher == null ? null : homeroomTeacher.getFullName(),
                null,
                true
        );
    }

    private LessonShift resolveShift(int slotIndex) {
        return slotIndex <= AFTERNOON_SLOT_OFFSET
                ? LessonShift.MORNING
                : LessonShift.AFTERNOON;
    }

    private int toDisplaySlotIndex(int slotIndex, LessonShift shift) {
        return shift == LessonShift.AFTERNOON
                ? slotIndex - AFTERNOON_SLOT_OFFSET
                : slotIndex;
    }

    private void validateSemesterBelongsToClass(
            Semester semester,
            SchoolClass schoolClass
    ) {
        if (!semester.getAcademicYearId().equals(
                schoolClass.getAcademicYear().getId()
        )) {
            throw new BusinessException(
                    ErrorCode.INVALID_REQUEST,
                    HttpStatus.BAD_REQUEST,
                    "Học kỳ không thuộc năm học của lớp chủ nhiệm"
            );
        }
    }

    private void validateSelectedStudyGroup(
            Long studyGroupId,
            List<StudyGroup> studyGroups
    ) {
        if (studyGroupId == null) {
            return;
        }
        boolean belongsToClass = studyGroups.stream()
                .anyMatch(group -> group.getId().equals(studyGroupId));
        if (!belongsToClass) {
            throw new BusinessException(
                    ErrorCode.INVALID_REQUEST,
                    HttpStatus.BAD_REQUEST,
                    "Cụm môn không thuộc lớp chủ nhiệm"
            );
        }
    }

    private BusinessException homeroomAccessDenied() {
        return new BusinessException(
                ErrorCode.FORBIDDEN,
                HttpStatus.FORBIDDEN,
                "Bạn không có quyền xem lớp chủ nhiệm này"
        );
    }
}
