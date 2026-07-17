package com.myfschool.notification;

import com.myfschool.account.Account;
import com.myfschool.student.Student;
import jakarta.persistence.CascadeType;
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
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;

@Entity
@Table(name = "notification")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 50)
    private NotificationType type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_student_id")
    private Student relatedStudent;

    @Column(name = "related_entity_type", length = 50)
    private String relatedEntityType;

    @Column(name = "related_entity_id")
    private Long relatedEntityId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_account_id")
    private Account createdByAccount;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "notification", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<NotificationRecipient> recipients = new LinkedHashSet<>();

    protected Notification() {
    }

    public Notification(
            String title,
            String content,
            NotificationType type,
            Student relatedStudent,
            String relatedEntityType,
            Long relatedEntityId,
            Account createdByAccount
    ) {
        this.title = title;
        this.content = content;
        this.type = type;
        this.relatedStudent = relatedStudent;
        this.relatedEntityType = relatedEntityType;
        this.relatedEntityId = relatedEntityId;
        this.createdByAccount = createdByAccount;
    }

    public NotificationRecipient addRecipient(Account account) {
        var recipient = new NotificationRecipient(this, account);
        recipients.add(recipient);
        return recipient;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getContent() {
        return content;
    }

    public NotificationType getType() {
        return type;
    }

    public Student getRelatedStudent() {
        return relatedStudent;
    }

    public String getRelatedEntityType() {
        return relatedEntityType;
    }

    public Long getRelatedEntityId() {
        return relatedEntityId;
    }

    public Account getCreatedByAccount() {
        return createdByAccount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public Set<NotificationRecipient> getRecipients() {
        return Set.copyOf(recipients);
    }
}
