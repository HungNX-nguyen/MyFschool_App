package com.myfschool.leaveabsence;

import com.myfschool.academic.SchoolClass;
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
import jakarta.persistence.UniqueConstraint;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "absence_record",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_absence_record_student_date_source",
                columnNames = {"student_id", "absence_date", "source"}
        )
)
public class AbsenceRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "class_id", nullable = false)
    private SchoolClass schoolClass;

    @Column(name = "absence_date", nullable = false)
    private LocalDate absenceDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private AbsenceStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "source", nullable = false, length = 30)
    private AbsenceSource source;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "leave_request_id")
    private LeaveRequest leaveRequest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recorded_by_teacher_id")
    private Teacher recordedByTeacher;

    @Column(name = "note", columnDefinition = "TEXT")
    private String note;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected AbsenceRecord() {
    }

    public AbsenceRecord(
            Student student,
            SchoolClass schoolClass,
            LocalDate absenceDate,
            AbsenceStatus status,
            AbsenceSource source,
            LeaveRequest leaveRequest,
            Teacher recordedByTeacher,
            String note
    ) {
        this.student = student;
        this.schoolClass = schoolClass;
        this.absenceDate = absenceDate;
        this.status = status;
        this.source = source;
        this.leaveRequest = leaveRequest;
        this.recordedByTeacher = recordedByTeacher;
        this.note = normalizeNote(note);
    }

    public Long getId() {
        return id;
    }

    public Student getStudent() {
        return student;
    }

    public SchoolClass getSchoolClass() {
        return schoolClass;
    }

    public LocalDate getAbsenceDate() {
        return absenceDate;
    }

    public AbsenceStatus getStatus() {
        return status;
    }

    public AbsenceSource getSource() {
        return source;
    }

    public LeaveRequest getLeaveRequest() {
        return leaveRequest;
    }

    public Teacher getRecordedByTeacher() {
        return recordedByTeacher;
    }

    public String getNote() {
        return note;
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
