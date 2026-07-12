package com.myfschool.account;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AccountRoleRepository extends JpaRepository<AccountRole, Long> {

    List<AccountRole> findAllByAccountIdAndStatus(Long accountId, AccountRoleStatus status);
}
