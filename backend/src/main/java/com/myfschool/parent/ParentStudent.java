package com.myfschool.parent;

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

@Entity
@Table(name = "parent_student")
public class ParentStudent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "parent_id", nullable = false)
    private Parent parent;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @Column(name = "relationship", length = 50)
    private String relationship;

    @Column(name = "is_primary_contact", nullable = false)
    private boolean primaryContact;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private ParentStudentStatus status = ParentStudentStatus.ACTIVE;

    protected ParentStudent() {
    }

    public Long getId() {
        return id;
    }

    public Parent getParent() {
        return parent;
    }

    public Student getStudent() {
        return student;
    }

    public String getRelationship() {
        return relationship;
    }

    public boolean isPrimaryContact() {
        return primaryContact;
    }

    public ParentStudentStatus getStatus() {
        return status;
    }
}
