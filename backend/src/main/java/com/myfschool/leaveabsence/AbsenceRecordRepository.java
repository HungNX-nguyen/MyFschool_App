package com.myfschool.leaveabsence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface AbsenceRecordRepository extends JpaRepository<AbsenceRecord, Long> {

    boolean existsByStudentIdAndAbsenceDateAndSource(
            Long studentId,
            LocalDate absenceDate,
            AbsenceSource source
    );

    List<AbsenceRecord> findByLeaveRequestIdOrderByAbsenceDateAsc(Long leaveRequestId);
}
