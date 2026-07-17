package com.myfschool.academic;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StudyGroupRepository extends JpaRepository<StudyGroup, Long> {

    List<StudyGroup> findBySchoolClassIdAndStatusOrderByGroupNameAsc(
            Long classId,
            StudyGroupStatus status
    );
}
