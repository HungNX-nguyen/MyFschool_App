package com.myfschool.grade;

import com.myfschool.academic.SchoolClass;
import com.myfschool.academic.Semester;
import com.myfschool.academic.Subject;
import com.myfschool.account.Account;
import com.myfschool.student.Student;
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

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "learning_result")
public class LearningResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "class_id", nullable = false)
    private SchoolClass schoolClass;

    @Column(name = "academic_year_id", nullable = false)
    private Long academicYearId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "semester_id")
    private Semester semester;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_id")
    private Subject subject;

    @Enumerated(EnumType.STRING)
    @Column(name = "result_type", nullable = false, length = 30)
    private LearningResultType resultType;

    @Column(name = "average_score", precision = 4, scale = 2)
    private BigDecimal averageScore;

    @Column(name = "rank_label", length = 50)
    private String rankLabel;

    @Column(name = "conduct_label", length = 50)
    private String conductLabel;

    @Column(name = "promotion_status", length = 50)
    private String promotionStatus;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_finalized", nullable = false)
    private boolean finalized;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "finalized_by_account_id")
    private Account finalizedByAccount;

    @Column(name = "finalized_at")
    private LocalDateTime finalizedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected LearningResult() {
    }

    public LearningResult(
            Student student,
            SchoolClass schoolClass,
            Long academicYearId,
            Semester semester,
            Subject subject,
            LearningResultType resultType
    ) {
        this.student = student;
        this.schoolClass = schoolClass;
        this.academicYearId = academicYearId;
        this.semester = semester;
        this.subject = subject;
        this.resultType = resultType;
    }

    public void finalizeSnapshot(
            BigDecimal averageScore,
            String rankLabel,
            String conductLabel,
            String promotionStatus,
            String description,
            Account finalizedByAccount,
            LocalDateTime finalizedAt
    ) {
        this.averageScore = averageScore;
        this.rankLabel = rankLabel;
        this.conductLabel = conductLabel;
        this.promotionStatus = promotionStatus;
        this.description = normalizeDescription(description);
        this.finalizedByAccount = finalizedByAccount;
        this.finalizedAt = finalizedAt;
        this.finalized = true;
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

    public Long getAcademicYearId() {
        return academicYearId;
    }

    public Semester getSemester() {
        return semester;
    }

    public Subject getSubject() {
        return subject;
    }

    public LearningResultType getResultType() {
        return resultType;
    }

    public BigDecimal getAverageScore() {
        return averageScore;
    }

    public String getRankLabel() {
        return rankLabel;
    }

    public String getConductLabel() {
        return conductLabel;
    }

    public String getPromotionStatus() {
        return promotionStatus;
    }

    public String getDescription() {
        return description;
    }

    public boolean isFinalized() {
        return finalized;
    }

    public Account getFinalizedByAccount() {
        return finalizedByAccount;
    }

    public LocalDateTime getFinalizedAt() {
        return finalizedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    private String normalizeDescription(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
