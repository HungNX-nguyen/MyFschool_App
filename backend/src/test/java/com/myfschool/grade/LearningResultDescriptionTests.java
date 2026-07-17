package com.myfschool.grade;

import com.myfschool.grade.dto.CalculateLearningResultRequest;
import jakarta.validation.Validation;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class LearningResultDescriptionTests {

    @Test
    void normalizesDescriptionWhenFinalizingSummary() {
        var result = summaryResult();

        result.finalizeSnapshot(
                BigDecimal.valueOf(7.82),
                "Khá",
                "Tốt",
                null,
                "  Em có ý thức học tập tốt.  ",
                null,
                LocalDateTime.now()
        );

        assertThat(result.getDescription()).isEqualTo("Em có ý thức học tập tốt.");
    }

    @Test
    void convertsBlankDescriptionToNull() {
        var result = summaryResult();

        result.finalizeSnapshot(
                BigDecimal.valueOf(7.82),
                "Khá",
                "Tốt",
                null,
                "   ",
                null,
                LocalDateTime.now()
        );

        assertThat(result.getDescription()).isNull();
    }

    @Test
    void rejectsDescriptionLongerThanTwoThousandCharacters() {
        try (var validatorFactory = Validation.buildDefaultValidatorFactory()) {
            var request = new CalculateLearningResultRequest(
                    1L,
                    1L,
                    LearningResultPeriod.SEMESTER_1,
                    "Tốt",
                    "a".repeat(2001)
            );

            var violations = validatorFactory.getValidator().validate(request);

            assertThat(violations)
                    .anySatisfy(violation ->
                            assertThat(violation.getPropertyPath().toString())
                                    .isEqualTo("description")
                    );
        }
    }

    private LearningResult summaryResult() {
        return new LearningResult(
                null,
                null,
                1L,
                null,
                null,
                LearningResultType.SEMESTER_SUMMARY
        );
    }
}
