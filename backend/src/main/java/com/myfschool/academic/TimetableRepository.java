package com.myfschool.academic;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface TimetableRepository extends JpaRepository<Timetable, Long> {

    @Query("""
            select timetable
            from Timetable timetable
            join fetch timetable.semester semester
            join fetch timetable.schoolClass schoolClass
            join fetch timetable.subject
            join fetch timetable.teacher
            left join fetch timetable.lessonSlot
            left join fetch timetable.studyGroup studyGroup
            where schoolClass.id = :classId
              and semester.id = :semesterId
              and (
                timetable.studyGroup is null
                or studyGroup.id = :studyGroupId
              )
              and timetable.status = :status
              and timetable.effectiveFrom <= :weekEnd
              and (
                timetable.effectiveTo is null
                or timetable.effectiveTo >= :weekStart
              )
            order by timetable.dayOfWeek asc, timetable.slotIndex asc
            """)
    List<Timetable> findClassTimetableForWeek(
            @Param("classId") Long classId,
            @Param("semesterId") Long semesterId,
            @Param("studyGroupId") Long studyGroupId,
            @Param("status") TimetableStatus status,
            @Param("weekStart") LocalDate weekStart,
            @Param("weekEnd") LocalDate weekEnd
    );

    @Query("""
            select timetable
            from Timetable timetable
            join fetch timetable.semester semester
            join fetch timetable.schoolClass schoolClass
            join fetch timetable.subject
            join fetch timetable.teacher
            left join fetch timetable.lessonSlot
            left join fetch timetable.studyGroup studyGroup
            where schoolClass.id = :classId
              and semester.id = :semesterId
              and (
                :studyGroupId is null
                or timetable.studyGroup is null
                or studyGroup.id = :studyGroupId
              )
              and timetable.status = :status
              and timetable.effectiveFrom <= :weekEnd
              and (
                timetable.effectiveTo is null
                or timetable.effectiveTo >= :weekStart
              )
            order by timetable.dayOfWeek asc, timetable.slotIndex asc,
                     studyGroup.groupName asc
            """)
    List<Timetable> findHomeroomClassTimetableForWeek(
            @Param("classId") Long classId,
            @Param("semesterId") Long semesterId,
            @Param("studyGroupId") Long studyGroupId,
            @Param("status") TimetableStatus status,
            @Param("weekStart") LocalDate weekStart,
            @Param("weekEnd") LocalDate weekEnd
    );

    @Query("""
            select timetable
            from Timetable timetable
            join fetch timetable.semester semester
            join fetch timetable.schoolClass
            join fetch timetable.subject
            join fetch timetable.teacher teacher
            left join fetch timetable.lessonSlot
            left join fetch timetable.studyGroup
            where teacher.id = :teacherId
              and semester.id = :semesterId
              and timetable.status = :status
              and timetable.effectiveFrom <= :weekEnd
              and (
                timetable.effectiveTo is null
                or timetable.effectiveTo >= :weekStart
              )
            order by timetable.dayOfWeek asc, timetable.slotIndex asc,
                     timetable.schoolClass.classCode asc
            """)
    List<Timetable> findTeacherTimetableForWeek(
            @Param("teacherId") Long teacherId,
            @Param("semesterId") Long semesterId,
            @Param("status") TimetableStatus status,
            @Param("weekStart") LocalDate weekStart,
            @Param("weekEnd") LocalDate weekEnd
    );
}
