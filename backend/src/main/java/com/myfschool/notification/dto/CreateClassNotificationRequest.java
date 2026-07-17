package com.myfschool.notification.dto;

import com.myfschool.notification.NotificationRecipientType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateClassNotificationRequest(
        @NotBlank(message = "Tiêu đề là bắt buộc")
        @Size(max = 255, message = "Tiêu đề không được vượt quá 255 ký tự")
        String title,

        @NotBlank(message = "Nội dung là bắt buộc")
        String content,

        @NotNull(message = "Đối tượng nhận là bắt buộc")
        NotificationRecipientType recipientType
) {
}
