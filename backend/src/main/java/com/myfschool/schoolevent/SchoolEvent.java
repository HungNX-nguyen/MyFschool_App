package com.myfschool.schoolevent;

import com.myfschool.academic.SchoolClass;
import com.myfschool.account.Account;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "school_event")
public class SchoolEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "scope", nullable = false, length = 20)
    private SchoolEventScope scope;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "class_id")
    private SchoolClass schoolClass;

    @Column(name = "event_date", nullable = false)
    private LocalDate eventDate;

    @Column(name = "start_time")
    private LocalTime startTime;

    @Column(name = "end_time")
    private LocalTime endTime;

    @Column(name = "is_all_day", nullable = false)
    private boolean allDay;

    @Column(name = "location", length = 255)
    private String location;

    @Enumerated(EnumType.STRING)
    @Column(name = "participation_type", nullable = false, length = 20)
    private SchoolEventParticipationType participationType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private SchoolEventStatus status = SchoolEventStatus.DRAFT;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "created_by_account_id", nullable = false)
    private Account createdByAccount;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @Column(name = "cancellation_reason", columnDefinition = "TEXT")
    private String cancellationReason;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected SchoolEvent() {
    }

    public static SchoolEvent createClassEvent(
            String title,
            String description,
            SchoolClass schoolClass,
            LocalDate eventDate,
            LocalTime startTime,
            LocalTime endTime,
            boolean allDay,
            String location,
            SchoolEventParticipationType participationType,
            Account createdByAccount
    ) {
        var event = new SchoolEvent();
        event.title = title;
        event.description = description;
        event.scope = SchoolEventScope.CLASS;
        event.schoolClass = schoolClass;
        event.eventDate = eventDate;
        event.startTime = startTime;
        event.endTime = endTime;
        event.allDay = allDay;
        event.location = location;
        event.participationType = participationType;
        event.status = SchoolEventStatus.DRAFT;
        event.createdByAccount = createdByAccount;
        return event;
    }

    public void publish(LocalDateTime publishTime) {
        status = SchoolEventStatus.PUBLISHED;
        publishedAt = publishTime;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public SchoolEventScope getScope() {
        return scope;
    }

    public SchoolClass getSchoolClass() {
        return schoolClass;
    }

    public LocalDate getEventDate() {
        return eventDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public boolean isAllDay() {
        return allDay;
    }

    public String getLocation() {
        return location;
    }

    public SchoolEventParticipationType getParticipationType() {
        return participationType;
    }

    public SchoolEventStatus getStatus() {
        return status;
    }

    public Account getCreatedByAccount() {
        return createdByAccount;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}
