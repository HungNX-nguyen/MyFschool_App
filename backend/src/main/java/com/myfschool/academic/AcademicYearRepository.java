package com.myfschool.academic;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface AcademicYearRepository extends JpaRepository<AcademicYear, Long> {

    Optional<AcademicYear> findFirstByStatusOrderByStartDateDesc(
            AcademicYearStatus status
    );

    List<AcademicYear> findByIdInOrderByStartDateDesc(Collection<Long> ids);
}
