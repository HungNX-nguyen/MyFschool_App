package com.myfschool.leaveabsence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {

    @Query("""
            select request
            from LeaveRequest request
            join fetch request.student
            join fetch request.parent
            join fetch request.schoolClass
            left join fetch request.reviewedByTeacher
            where request.parent.id = :parentId
              and request.student.id = :studentId
              and (:status is null or request.status = :status)
            order by request.createdAt desc, request.id desc
            """)
    List<LeaveRequest> findForParent(
            @Param("parentId") Long parentId,
            @Param("studentId") Long studentId,
            @Param("status") LeaveRequestStatus status
    );

    @Query("""
            select request
            from LeaveRequest request
            join fetch request.student
            join fetch request.parent
            join fetch request.schoolClass
            left join fetch request.reviewedByTeacher
            where request.schoolClass.id = :classId
              and (:status is null or request.status = :status)
            order by request.createdAt desc, request.id desc
            """)
    List<LeaveRequest> findForHomeroomClass(
            @Param("classId") Long classId,
            @Param("status") LeaveRequestStatus status
    );

    @Query("""
            select request
            from LeaveRequest request
            join fetch request.student
            join fetch request.parent
            join fetch request.schoolClass
            left join fetch request.reviewedByTeacher
            where request.id = :requestId
            """)
    Optional<LeaveRequest> findDetailedById(@Param("requestId") Long requestId);

    @Query("""
            select count(request)
            from LeaveRequest request
            where request.student.id = :studentId
              and request.status in :statuses
              and request.fromDate <= :toDate
              and request.toDate >= :fromDate
            """)
    long countOverlappingRequests(
            @Param("studentId") Long studentId,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate,
            @Param("statuses") Collection<LeaveRequestStatus> statuses
    );
}
