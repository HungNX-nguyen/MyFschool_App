package com.myfschool.academic;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SchoolClassRepository extends JpaRepository<SchoolClass, Long> {

    @Query("""
            select schoolClass
            from SchoolClass schoolClass
            where schoolClass.homeroomTeacher.id = :teacherId
              and schoolClass.academicYear.id = :academicYearId
            order by schoolClass.classCode asc
            """)
    List<SchoolClass> findHomeroomClasses(
            @Param("teacherId") Long teacherId,
            @Param("academicYearId") Long academicYearId
    );

    @Query("""
            select schoolClass
            from SchoolClass schoolClass
            join fetch schoolClass.academicYear academicYear
            join fetch schoolClass.homeroomTeacher homeroomTeacher
            where homeroomTeacher.id = :teacherId
            order by academicYear.startDate desc, schoolClass.classCode asc
            """)
    List<SchoolClass> findAllHomeroomClasses(
            @Param("teacherId") Long teacherId
    );

    @Query("""
            select schoolClass
            from SchoolClass schoolClass
            join fetch schoolClass.academicYear academicYear
            join fetch schoolClass.homeroomTeacher homeroomTeacher
            where schoolClass.id = :classId
              and homeroomTeacher.id = :teacherId
            """)
    Optional<SchoolClass> findHomeroomClass(
            @Param("classId") Long classId,
            @Param("teacherId") Long teacherId
    );
}
