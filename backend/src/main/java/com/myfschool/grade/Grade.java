package com.myfschool.grade;

import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.Semester;
import com.myfschool.academic.Subject;
import com.myfschool.account.Account;
import com.myfschool.student.Student;
import com.myfschool.teacher.Teacher;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "grade")
public class Grade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "class_id", nullable = false)
    private SchoolClass schoolClass;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "semester_id", nullable = false)
    private Semester semester;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "grade_component_id", nullable = false)
    private GradeComponent gradeComponent;

    @Column(name = "score", nullable = false, precision = 4, scale = 2)
    private BigDecimal score;

    @Column(name = "weight", nullable = false, precision = 5, scale = 2)
    private BigDecimal weight;

    @Column(name = "attempt_no", nullable = false)
    private Integer attemptNo;

    @Column(name = "is_published", nullable = false)
    private boolean published;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "entered_by_teacher_id", nullable = false)
    private Teacher enteredByTeacher;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by_account_id")
    private Account updatedByAccount;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    protected Grade() {
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

    public Subject getSubject() {
        return subject;
    }

    public Semester getSemester() {
        return semester;
    }

    public GradeComponent getGradeComponent() {
        return gradeComponent;
    }

    public BigDecimal getScore() {
        return score;
    }

    public BigDecimal getWeight() {
        return weight;
    }

    public Integer getAttemptNo() {
        return attemptNo;
    }

    public boolean isPublished() {
        return published;
    }

    public Teacher getEnteredByTeacher() {
        return enteredByTeacher;
    }

    public Account getUpdatedByAccount() {
        return updatedByAccount;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }
}
