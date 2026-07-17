package com.myfschool.grade;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GradeRepository extends JpaRepository<Grade, Long> {

    @Query("""
            select grade
            from Grade grade
            join fetch grade.subject
            join fetch grade.gradeComponent
            where grade.student.id = :studentId
              and grade.schoolClass.id = :classId
              and grade.semester.id = :semesterId
              and grade.published = true
            order by grade.subject.id, grade.gradeComponent.id, grade.attemptNo
            """)
    List<Grade> findPublishedForSemester(
            @Param("studentId") Long studentId,
            @Param("classId") Long classId,
            @Param("semesterId") Long semesterId
    );
}
