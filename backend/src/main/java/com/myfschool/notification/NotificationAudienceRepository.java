package com.myfschool.notification;

import com.myfschool.account.Account;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NotificationAudienceRepository extends Repository<Account, Long> {

    @Query("""
            select distinct account
            from StudentClassHistory history
            join history.student student
            join student.account account
            where history.schoolClass.id = :classId
              and history.academicYearId = :academicYearId
              and history.status = com.myfschool.student.StudentClassHistoryStatus.ACTIVE
              and student.status = com.myfschool.student.StudentStatus.ACTIVE
              and account.status = com.myfschool.account.AccountStatus.ACTIVE
            order by account.id
            """)
    List<Account> findActiveStudentAccounts(
            @Param("classId") Long classId,
            @Param("academicYearId") Long academicYearId
    );

    @Query("""
            select distinct account
            from ParentStudent parentStudent
            join parentStudent.parent parent
            join parent.account account
            where parentStudent.status = com.myfschool.parent.ParentStudentStatus.ACTIVE
              and parent.status = com.myfschool.parent.ParentStatus.ACTIVE
              and account.status = com.myfschool.account.AccountStatus.ACTIVE
              and parentStudent.student.id in (
                select history.student.id
                from StudentClassHistory history
                where history.schoolClass.id = :classId
                  and history.academicYearId = :academicYearId
                  and history.status = com.myfschool.student.StudentClassHistoryStatus.ACTIVE
                  and history.student.status = com.myfschool.student.StudentStatus.ACTIVE
              )
            order by account.id
            """)
    List<Account> findActiveParentAccounts(
            @Param("classId") Long classId,
            @Param("academicYearId") Long academicYearId
    );
}
