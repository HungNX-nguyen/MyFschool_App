package com.myfschool.student;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Long> {

    @Query("""
            select student
            from Student student
            left join fetch student.currentClass schoolClass
            left join fetch schoolClass.academicYear
            left join fetch schoolClass.homeroomTeacher
            where student.account.id = :accountId
            """)
    Optional<Student> findByAccountIdWithCurrentClass(
            @Param("accountId") Long accountId
    );
}
