package com.myfschool.teacher;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TeachingAssignmentRepository extends JpaRepository<TeachingAssignment, Long> {

    @Query("""
            select assignment
            from TeachingAssignment assignment
            join fetch assignment.schoolClass schoolClass
            join fetch assignment.subject subject
            join fetch assignment.academicYear academicYear
            left join fetch assignment.semester semester
            where assignment.teacher.id = :teacherId
              and academicYear.id = :academicYearId
              and assignment.status = :status
            order by subject.subjectName asc, schoolClass.classCode asc, assignment.id asc
            """)
    List<TeachingAssignment> findByTeacherAndAcademicYear(
            @Param("teacherId") Long teacherId,
            @Param("academicYearId") Long academicYearId,
            @Param("status") TeachingAssignmentStatus status
    );
}
