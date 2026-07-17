package com.myfschool.grade;

public enum LearningResultPeriod {
    SEMESTER_1(1),
    SEMESTER_2(2),
    ANNUAL(null);

    private final Integer semesterIndex;

    LearningResultPeriod(Integer semesterIndex) {
        this.semesterIndex = semesterIndex;
    }

    public Integer getSemesterIndex() {
        return semesterIndex;
    }

    public boolean isAnnual() {
        return this == ANNUAL;
    }
}
