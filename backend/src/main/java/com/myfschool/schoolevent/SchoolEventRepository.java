package com.myfschool.schoolevent;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface SchoolEventRepository extends JpaRepository<SchoolEvent, Long> {

    @Query("""
            select event
            from SchoolEvent event
            left join fetch event.schoolClass schoolClass
            where event.id = :eventId
              and event.status <> com.myfschool.schoolevent.SchoolEventStatus.DRAFT
            """)
    Optional<SchoolEvent> findAccessibleDetail(@Param("eventId") Long eventId);

    @Query("""
            select event
            from SchoolEvent event
            left join fetch event.schoolClass schoolClass
            where event.status = com.myfschool.schoolevent.SchoolEventStatus.PUBLISHED
              and (
                :scope is null
                or event.scope = :scope
              )
              and (
                event.scope = com.myfschool.schoolevent.SchoolEventScope.SCHOOL
                or schoolClass.id = :classId
              )
              and (
                (event.allDay = true and event.eventDate >= :currentDate)
                or (
                  event.allDay = false
                  and (
                    event.eventDate > :currentDate
                    or (
                      event.eventDate = :currentDate
                      and coalesce(event.endTime, event.startTime) >= :currentTime
                    )
                  )
                )
              )
            order by event.eventDate asc, event.startTime asc, event.id asc
            """)
    List<SchoolEvent> findUpcomingVisibleEvents(
            @Param("classId") Long classId,
            @Param("scope") SchoolEventScope scope,
            @Param("currentDate") LocalDate currentDate,
            @Param("currentTime") LocalTime currentTime
    );

    @Query("""
            select event
            from SchoolEvent event
            left join fetch event.schoolClass schoolClass
            where event.status = com.myfschool.schoolevent.SchoolEventStatus.PUBLISHED
              and (
                :scope is null
                or event.scope = :scope
              )
              and (
                event.scope = com.myfschool.schoolevent.SchoolEventScope.SCHOOL
                or schoolClass.id = :classId
              )
              and (
                (event.allDay = true and event.eventDate < :currentDate)
                or (
                  event.allDay = false
                  and (
                    event.eventDate < :currentDate
                    or (
                      event.eventDate = :currentDate
                      and coalesce(event.endTime, event.startTime) < :currentTime
                    )
                  )
                )
              )
            order by event.eventDate desc, event.startTime desc, event.id desc
            """)
    List<SchoolEvent> findPastVisibleEvents(
            @Param("classId") Long classId,
            @Param("scope") SchoolEventScope scope,
            @Param("currentDate") LocalDate currentDate,
            @Param("currentTime") LocalTime currentTime
    );
}
