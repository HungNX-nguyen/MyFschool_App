package com.myfschool.leaveabsence;

import com.myfschool.academic.SchoolClass;
import com.myfschool.parent.Parent;
import com.myfschool.student.Student;
import com.myfschool.teacher.Teacher;
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

@Entity
@Table(name = "leave_request")
public class LeaveRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "parent_id", nullable = false)
    private Parent parent;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "class_id", nullable = false)
    private SchoolClass schoolClass;

    @Column(name = "from_date", nullable = false)
    private LocalDate fromDate;

    @Column(name = "to_date", nullable = false)
    private LocalDate toDate;

    @Column(name = "reason", nullable = false, columnDefinition = "TEXT")
    private String reason;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private LeaveRequestStatus status = LeaveRequestStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by_teacher_id")
    private Teacher reviewedByTeacher;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    @Column(name = "review_note", columnDefinition = "TEXT")
    private String reviewNote;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected LeaveRequest() {
    }

    public LeaveRequest(
            Student student,
            Parent parent,
            SchoolClass schoolClass,
            LocalDate fromDate,
            LocalDate toDate,
            String reason
    ) {
        this.student = student;
        this.parent = parent;
        this.schoolClass = schoolClass;
        this.fromDate = fromDate;
        this.toDate = toDate;
        this.reason = reason;
    }

    public void cancel() {
        this.status = LeaveRequestStatus.CANCELLED;
    }

    public void approve(Teacher reviewer, LocalDateTime reviewTime, String note) {
        this.status = LeaveRequestStatus.APPROVED;
        this.reviewedByTeacher = reviewer;
        this.reviewedAt = reviewTime;
        this.reviewNote = normalizeNote(note);
    }

    public void reject(Teacher reviewer, LocalDateTime reviewTime, String note) {
        this.status = LeaveRequestStatus.REJECTED;
        this.reviewedByTeacher = reviewer;
        this.reviewedAt = reviewTime;
        this.reviewNote = normalizeNote(note);
    }

    public Long getId() {
        return id;
    }

    public Student getStudent() {
        return student;
    }

    public Parent getParent() {
        return parent;
    }

    public SchoolClass getSchoolClass() {
        return schoolClass;
    }

    public LocalDate getFromDate() {
        return fromDate;
    }

    public LocalDate getToDate() {
        return toDate;
    }

    public String getReason() {
        return reason;
    }

    public LeaveRequestStatus getStatus() {
        return status;
    }

    public Teacher getReviewedByTeacher() {
        return reviewedByTeacher;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public String getReviewNote() {
        return reviewNote;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    private String normalizeNote(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
