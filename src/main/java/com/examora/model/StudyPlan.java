package com.examora.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * StudyPlan represents a student's configured preparation timeline and parameters.
 * 
 * WHAT: Model POJO mapping to the 'study_plans' table in MySQL.
 * WHY: Contains parameters defining start/end dates, daily study hour budgets, and focus preferences.
 * HOW: Declares standard properties with getters/setters.
 * WHERE: Placed in the com.examora.model package.
 */
public class StudyPlan {
    private int id;
    private int userId;
    private int examId;
    private LocalDate startDate;
    private LocalDate endDate;
    private double dailyStudyHours;
    private String preferredDays; // Mon,Tue,Wed...
    private String status; // ACTIVE, COMPLETED, ARCHIVED
    private LocalDateTime createdAt;

    // Student milestones set targets
    private LocalDate targetSyllabusCompletionDate;
    private LocalDate targetPyqCompletionDate;
    private int revisionBufferDays = 14;

    // Study modes splits percentages
    private int learnPct = 50;
    private int practicePct = 30;
    private int revisionPct = 20;

    // Constructors
    public StudyPlan() {}

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public double getDailyStudyHours() {
        return dailyStudyHours;
    }

    public void setDailyStudyHours(double dailyStudyHours) {
        this.dailyStudyHours = dailyStudyHours;
    }

    public String getPreferredDays() {
        return preferredDays;
    }

    public void setPreferredDays(String preferredDays) {
        this.preferredDays = preferredDays;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDate getTargetSyllabusCompletionDate() {
        return targetSyllabusCompletionDate;
    }

    public void setTargetSyllabusCompletionDate(LocalDate targetSyllabusCompletionDate) {
        this.targetSyllabusCompletionDate = targetSyllabusCompletionDate;
    }

    public LocalDate getTargetPyqCompletionDate() {
        return targetPyqCompletionDate;
    }

    public void setTargetPyqCompletionDate(LocalDate targetPyqCompletionDate) {
        this.targetPyqCompletionDate = targetPyqCompletionDate;
    }

    public int getRevisionBufferDays() {
        return revisionBufferDays;
    }

    public void setRevisionBufferDays(int revisionBufferDays) {
        this.revisionBufferDays = revisionBufferDays;
    }

    public int getLearnPct() {
        return learnPct;
    }

    public void setLearnPct(int learnPct) {
        this.learnPct = learnPct;
    }

    public int getPracticePct() {
        return practicePct;
    }

    public void setPracticePct(int practicePct) {
        this.practicePct = practicePct;
    }

    public int getRevisionPct() {
        return revisionPct;
    }

    public void setRevisionPct(int revisionPct) {
        this.revisionPct = revisionPct;
    }
}
