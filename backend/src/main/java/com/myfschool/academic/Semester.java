package com.myfschool.academic;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDate;

@Entity
@Table(name = "semester")
public class Semester {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "academic_year_id", nullable = false)
    private Long academicYearId;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    @Column(name = "semester_index", nullable = false)
    private Integer semesterIndex;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private SemesterStatus status;

    protected Semester() {
    }

    public Long getId() {
        return id;
    }

    public Long getAcademicYearId() {
        return academicYearId;
    }

    public String getName() {
        return name;
    }

    public Integer getSemesterIndex() {
        return semesterIndex;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public SemesterStatus getStatus() {
        return status;
    }
}
