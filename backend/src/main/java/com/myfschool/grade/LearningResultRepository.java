package com.myfschool.grade;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface LearningResultRepository extends JpaRepository<LearningResult, Long> {

    @Query("""
            select result
            from LearningResult result
            left join fetch result.semester
            left join fetch result.subject
            where result.student.id = :studentId
              and result.schoolClass.id = :classId
              and result.academicYearId = :academicYearId
            """)
    List<LearningResult> findForScope(
            @Param("studentId") Long studentId,
            @Param("classId") Long classId,
            @Param("academicYearId") Long academicYearId
    );

    @Query("""
            select result
            from LearningResult result
            left join fetch result.semester
            left join fetch result.subject
            where result.student.id = :studentId
              and result.academicYearId = :academicYearId
              and result.finalized = true
            """)
    List<LearningResult> findFinalizedForStudentAndYear(
            @Param("studentId") Long studentId,
            @Param("academicYearId") Long academicYearId
    );

    @Query("""
            select distinct result.academicYearId
            from LearningResult result
            where result.student.id = :studentId
              and result.finalized = true
            """)
    List<Long> findFinalizedAcademicYearIds(
            @Param("studentId") Long studentId
    );
}
