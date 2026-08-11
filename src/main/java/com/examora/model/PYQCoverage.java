package com.examora.model;

/**
 * PYQCoverage represents the year-wise practice and past paper questions coverage stats.
 */
public class PYQCoverage {
    private int id;
    private int examId;
    private int subjectId;
    private int year;
    private int questionCount;
    private int verifiedCount;
    private String sourceUrl;
    private String ingestionStatus; // NOT_STARTED, IN_PROGRESS, COMPLETE

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public int getVerifiedCount() {
        return verifiedCount;
    }

    public void setVerifiedCount(int verifiedCount) {
        this.verifiedCount = verifiedCount;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public void setSourceUrl(String sourceUrl) {
        this.sourceUrl = sourceUrl;
    }

    public String getIngestionStatus() {
        return ingestionStatus;
    }

    public void setIngestionStatus(String ingestionStatus) {
        this.ingestionStatus = ingestionStatus;
    }
}
