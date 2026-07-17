package com.myfschool.student;

import com.myfschool.academic.StudyGroupStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Optional;

public interface StudentStudyGroupRepository extends JpaRepository<StudentStudyGroup, Long> {

    @Query("""
            select membership
            from StudentStudyGroup membership
            join fetch membership.studyGroup studyGroup
            join fetch studyGroup.schoolClass
            join fetch membership.semester semester
            where membership.student.id = :studentId
              and semester.id = :semesterId
              and membership.status = :membershipStatus
              and studyGroup.status = :groupStatus
              and membership.effectiveFrom <= :weekEnd
              and (
                membership.effectiveTo is null
                or membership.effectiveTo >= :weekStart
              )
            """)
    Optional<StudentStudyGroup> findActiveForWeek(
            @Param("studentId") Long studentId,
            @Param("semesterId") Long semesterId,
            @Param("membershipStatus") StudentStudyGroupStatus membershipStatus,
            @Param("groupStatus") StudyGroupStatus groupStatus,
            @Param("weekStart") LocalDate weekStart,
            @Param("weekEnd") LocalDate weekEnd
    );
}
