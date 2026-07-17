package com.myfschool.leaveabsence.dto;

import com.myfschool.leaveabsence.LeaveRequestStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ReviewLeaveRequestRequest(
        @NotNull LeaveRequestStatus decision,
        @Size(max = 2000) String reviewNote
) {
}
