package com.myfschool.student;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface StudentClassHistoryRepository
        extends JpaRepository<StudentClassHistory, Long> {

    @Query("""
            select distinct history.student.id
            from StudentClassHistory history
            where history.schoolClass.id = :classId
              and history.academicYearId = :academicYearId
              and history.status in :statuses
            order by history.student.id
            """)
    List<Long> findStudentIdsForClassAndYear(
            @Param("classId") Long classId,
            @Param("academicYearId") Long academicYearId,
            @Param("statuses") Collection<StudentClassHistoryStatus> statuses
    );

    @Query("""
            select distinct student
            from StudentClassHistory history
            join history.student student
            where history.schoolClass.id = :classId
              and history.academicYearId = :academicYearId
              and history.status = :historyStatus
              and student.status = :studentStatus
            order by student.fullName asc, student.studentCode asc
            """)
    List<Student> findActiveStudentsForClassAndYear(
            @Param("classId") Long classId,
            @Param("academicYearId") Long academicYearId,
            @Param("historyStatus") StudentClassHistoryStatus historyStatus,
            @Param("studentStatus") StudentStatus studentStatus
    );
}
