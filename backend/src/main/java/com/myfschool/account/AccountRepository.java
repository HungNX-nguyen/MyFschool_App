package com.myfschool.account;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Long> {

    @Query("""
            select distinct account
            from Account account
            left join fetch account.roles
            where account.username = :identifier
               or account.phone = :identifier
            """)
    Optional<Account> findForAuthentication(@Param("identifier") String identifier);

    @Query("""
            select distinct account
            from Account account
            left join fetch account.roles
            where account.id = :accountId
            """)
    Optional<Account> findForSecurityById(@Param("accountId") Long accountId);
}
