package com.myfschool.parent;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ParentStudentRepository extends JpaRepository<ParentStudent, Long> {

    @Query("""
            select parentStudent
            from ParentStudent parentStudent
            join fetch parentStudent.student student
            left join fetch student.currentClass schoolClass
            left join fetch schoolClass.academicYear
            where parentStudent.parent.id = :parentId
              and parentStudent.status = :status
            order by student.fullName asc, student.id asc
            """)
    List<ParentStudent> findLinkedStudents(
            @Param("parentId") Long parentId,
            @Param("status") ParentStudentStatus status
    );

    @Query("""
            select parentStudent
            from ParentStudent parentStudent
            join fetch parentStudent.student student
            left join fetch student.currentClass schoolClass
            left join fetch schoolClass.academicYear
            left join fetch schoolClass.homeroomTeacher
            where parentStudent.parent.id = :parentId
              and student.id = :studentId
              and parentStudent.status = :status
            """)
    Optional<ParentStudent> findLinkedStudent(
            @Param("parentId") Long parentId,
            @Param("studentId") Long studentId,
            @Param("status") ParentStudentStatus status
    );
}
