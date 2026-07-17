package com.myfschool.academic;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface SemesterRepository extends JpaRepository<Semester, Long> {

    List<Semester> findByAcademicYearIdOrderBySemesterIndexAsc(Long academicYearId);

    List<Semester> findByAcademicYearIdInOrderByAcademicYearIdAscSemesterIndexAsc(
            Collection<Long> academicYearIds
    );

    Optional<Semester> findByAcademicYearIdAndSemesterIndex(
            Long academicYearId,
            Integer semesterIndex
    );

    @Query("""
            select semester
            from Semester semester
            where semester.status = :status
              and semester.startDate <= :weekEnd
              and semester.endDate >= :weekStart
            order by semester.startDate desc, semester.id desc
            """)
    List<Semester> findOverlappingWeek(
            @Param("status") SemesterStatus status,
            @Param("weekStart") LocalDate weekStart,
            @Param("weekEnd") LocalDate weekEnd
    );
}
