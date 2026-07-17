package com.myfschool.schoolevent.dto;

import com.myfschool.schoolevent.SchoolEventParticipationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;

public record CreateClassEventRequest(
        @NotBlank(message = "Tiêu đề sự kiện là bắt buộc")
        @Size(max = 255, message = "Tiêu đề không được vượt quá 255 ký tự")
        String title,

        String description,

        @NotNull(message = "Ngày diễn ra là bắt buộc")
        LocalDate eventDate,

        @NotNull(message = "Loại thời gian sự kiện là bắt buộc")
        Boolean allDay,

        LocalTime startTime,

        LocalTime endTime,

        @Size(max = 255, message = "Địa điểm không được vượt quá 255 ký tự")
        String location,

        @NotNull(message = "Loại tham gia là bắt buộc")
        SchoolEventParticipationType participationType,

        @NotNull(message = "Lựa chọn phát hành là bắt buộc")
        Boolean publishNow
) {
}
